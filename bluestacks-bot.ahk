#Include lib\Gdip_All.ahk
#Include lib\Gdip_ImageSearch.ahk

/**
 * Bot for Bluestacks 5
 * @constructor
 * @param {number | String} [hwndIdOrTitle=0]  hwnd id or title
 * @param {String} [imageFolderDir=A_ScriptDir] image folder directory
 */
class BsBot {
    __New(hwndIdOrTitle := 0, imageFolderDir := A_ScriptDir) {
        this._needleImgDir := (SubStr(imageFolderDir, -1) = '/')
            ? imageFolderDir
            : imageFolderDir . "/"
        this._hwnd := this._createHwndObject(hwndIdOrTitle)
    }

    _createHwndObject(idOrTitle) {
        try parentId := (Type(idOrTitle) = 'integer') ? idOrTitle : WinGetID(idOrTitle)
        catch as e {
            MsgBox("invalid hwnd", , "IconX")
            Exit
        }

        ; get child hwnd
        try childId := DllCall("GetWindow", "Ptr", parentId, "Uint", 5, "Ptr")
        catch as e {
            MsgBox("child hwnd not found", , "IconX")
            Exit
        }

        childTitle := WinGetTitle(childId)
        childClass := WinGetClass(childId)
        if (childTitle != "HD-Player" && childClass != "Qt5154QWindowIcon") {
            MsgBox("It's NOT a bluestacks emu.", , "IconX")
            Exit
        }

        return {
            id: childId,
            title: childTitle,
            class: childClass,
            parentId: parentId,
            parentTitle: WinGetTitle(parentId),
        }
    }

    ;* -------- getter
    getHwndObject() => this._hwnd

    ;* -------- error handler
    popErrorMessage(code, msg := "Gdip Error!!") {
        MsgBox(msg " (code: " code ")", "ERROR", "IconX")
        Exit
    }

    ;* -------- searchImage methods
    saveCurrentScreen() {
        pToken := Gdip_Startup()
        pHaystack := Gdip_BitmapFromScreen("hwnd:" . this._hwnd.id)

        Gdip_SaveBitmapToFile(pHaystack, "captured.png", 100)

        Gdip_DisposeImage(pHaystack)
        Gdip_Shutdown(pToken)
    }
    click(x, y) {
        lprm := x | y << 16

        ; active mouse for bluestacks
        PostMessage 6, 2, 0, this._hwnd.id, this._hwnd.title

        PostMessage 0x201, 1, lprm, this._hwnd.id, this._hwnd.title
        PostMessage 0x202, 0, lprm, this._hwnd.id, this._hwnd.title

        Sleep(300)
    }
    searchImage(fileName, count := 1, variation := 10, sX := 0, sY := 0, eX := 0, eY := 0) {
        needleImgFullDir := this._needleImgDir . fileName . ".bmp"

        pToken := Gdip_Startup()
        pNeedle := Gdip_CreateBitmapFromFile(needleImgFullDir)

        result := 0
        loopOut := false
        Loop count {
            Loop 5 {
                pHaystack := Gdip_BitmapFromScreen("hwnd:" . this._hwnd.id)
                result := Gdip_ImageSearch(pHaystack, pNeedle, &outputVar, sX, sY, eX, eY, variation)
                Gdip_DisposeImage(pHaystack)

                ; found // break inner loop
                if (result != 0) {
                    break
                }
                Sleep(200)
            }

            ; found // break outer loop
            if (result != 0) {
                break
            }
        }
        Gdip_DisposeImage(pNeedle)
        Gdip_Shutdown(pToken)

        if (result > 0) {
            posArr := StrSplit(outputVar, ",")
            return {
                x: posArr[1],
                y: posArr[2]
            }
        } else if (result < 0) { ; error
            this.popErrorMessage(result)
        }
        return false ; result = 0 (notfound)
    }
    getImgPos(fileName, count := 1) {
        return this.searchImage(fileName, count)
    }
    hasImg(fileName, count := 1) {
        return IsObject(this.searchImage(fileName, count))
    }
    clickImgPos(fileName, count := 1, beforeDelay := 0, afterDelay := 0) {
        ; before delay
        (beforeDelay > 0) && Sleep(beforeDelay)

        ; get pos then click on it
        posObj := this.getImgPos(fileName, count)
        if (!IsObject(posObj)) {
            return false
        }
        this.click(posObj.x, posObj.y)

        ; after delay
        (afterDelay > 0) && Sleep(afterDelay)
        return true
    }
}