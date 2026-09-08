# GIF del README. Regenerar desde la raiz del repo:
#
#   brew install vhs gifsicle
#   vhs docs/demo.tape
#   gifsicle -O3 --colors 16 -b docs/demo.gif
#
# El contenido lo escupe docs/demo.sh: es la salida real de `make ch11`
# replayeada, porque el build de UVM tarda minutos. Ver ese archivo.

Output docs/demo.gif

Set Shell bash
Set FontFamily "Menlo"
Set FontSize 17
Set Width 820
Set Height 470
Set Padding 16
Set Framerate 12
Set Theme { "background": "#111111", "foreground": "#e4e4e4", "cursor": "#5ec27a", "selection": "#333333", "black": "#111111", "red": "#e06c75", "green": "#5ec27a", "yellow": "#d9b06a", "blue": "#6ba7d9", "magenta": "#c08cd0", "cyan": "#5fb3b3", "white": "#e4e4e4", "brightBlack": "#7a7a7a", "brightRed": "#e06c75", "brightGreen": "#5ec27a", "brightYellow": "#d9b06a", "brightBlue": "#6ba7d9", "brightMagenta": "#c08cd0", "brightCyan": "#5fb3b3", "brightWhite": "#ffffff" }

Hide
Type "clear && bash docs/demo.sh" Enter
Show
Sleep 18s
