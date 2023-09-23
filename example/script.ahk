#Include ../bluestacks-bot.ahk

; Declaration
Bot := unset

/*
;!!! You have to follow this before do F6 or F7
; 1. Run Bluestacks
; 2. Capture bluestacks screen then crop it wherever you want
; 3. Save it as "your_image.bmp" into "img" folder
; 4. Run this script(test.ahk)
; 5. Press F5 (Make sure that bluestacks window is active and in focus)
; 6. If msgbox say "Let's start!", Now you can do F6 or F7
*/
F5:: {
    ; constructs an instance
    imageFolderDir := A_ScriptDir . "/img/"
    global Bot := BsBot(WinGetID("A"), imageFolderDir)
    MsgBox("Let's start!")
}

;* Example 1: Show all properties in the hwnd object that your instance created
F6:: {
    ; get a hwnd object
    hwndObj := Bot.getHwndObject()

    ; show all properties
    msg := ""
    for (k, v in hwndObj.OwnProps()) {
        msg .= "key: " k " , value: " v "`n"
    }
    MsgBox(msg)
}

;* Example 2: Some methods you can use
F7:: {
    ;? click the position(x,y)
    Bot.click(100, 200)
    MsgBox("just clicked on (100,200)")

    ;? check the current screen has an image
    hasImg := Bot.hasImg("your_image", 5)
    MsgBox(hasImg ? "found" : "not found")

    ;? get the image's position
    posObj := Bot.getImgPos("your_image", 3)
    MsgBox(IsObject(posObj) ? "x:" posObj.x " , y:" posObj.y : "not found")

    ;? click the image's position. it's the same as Bot.getImgPos() then Bot.click()
    isClicked := Bot.clickImgPos("your_image", , , 1000)
    MsgBox(isClicked ? "clicked" : "not found")
}

; kill this script
F8:: {
    ExitApp
}