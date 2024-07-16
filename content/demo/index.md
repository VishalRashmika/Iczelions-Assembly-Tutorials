+++
template = "article.html"
title = "File Archive"

+++
| Lesson Number        | Topic     | Files |
| :----------- | :---------------- | :---- |
| 1            | The Basics        | [win32asm.zip](../lessons/01/win32asm.zip)  |
| 2            |   MessageBox      | [tut02.zip](../lessons/02/tut02.zip)  |
| 3            | A Simple Window   | [tut03.zip](../lessons/03/tut03.zip)  |
| 4            | Paintin With Text | [tut04.zip](../lessons/04/tut04.zip)  |
| 5            | More About text   | [tut05.zip](../lessons/05/tut05.zip)  |

## There's a horizontal rule below this.

---

## Here is an unordered list:

- Item foo
- Item bar
- Item baz
- Item zip

## And an ordered list:

1. Item one
2. Item two
3. Item three
4. Item four

## And a nested list:

- level 1 item
  - level 2 item
  - level 2 item
    - level 3 item
    - level 3 item
- level 1 item
  - level 2 item
  - level 2 item
  - level 2 item
- level 1 item
  - level 2 item
  - level 2 item
- level 1 item

## Here are checkboxes:

- [ ] Milk
- [x] Eggs
- [x] Flour
- [ ] Coffee
- [x] Combustible lemons

### Same but interactive

<ul>
<li><input type="checkbox"> Milk</li>
<li><input checked="" type="checkbox"> Eggs</li>
<li><input checked="" type="checkbox"> Flour</li>
<li><input type="checkbox"> Coffee</li>
<li><input checked="" type="checkbox"> Combustible lemons</li>
</ul>

### With radio type

<ul>
<li><input type="radio" name="test"> Milk</li>
<li><input type="radio" name="test"> Eggs</li>
<li><input type="radio" name="test"> Flour</li>
<li><input checked="" type="radio" name="test"> Coffee</li>
<li><input type="radio" name="test" disabled=""> Combustible lemons</li>
</ul>

## Small image

{{ image(url="https://codeberg.org/Codeberg/Design/raw/branch/main/logo/icon/png/codeberg-logo_icon_blue-64x64.png", alt="Codeberg icon", transparent=true, no_hover=true) }}

## Large image

{{ image(url="https://codeberg.org/Codeberg/Design/raw/branch/main/logo/horizontal/png/codeberg-logo_horizontal_blue-850x250.png", alt="Codeberg horizontal", transparent=true, no_hover=true) }}

## Definition lists can be used with HTML syntax.

<dl>
<dt>Name</dt>
<dd>Godzilla</dd>
<dt>Born</dt>
<dd>1952</dd>
<dt>Birthplace</dt>
<dd>Japan</dd>
<dt>Color</dt>
<dd>Green</dd>
</dl>

```
Long, single-line code blocks should not wrap. They should horizontally scroll if they are too long. This line should be long enough to demonstrate this.
```

```
The final element.
```

## Extra

Alright now that the generic (slightly extended) ~~Jekyll~~ Zola demo page have ended, we can get to the custom stuff, which believe me, is neat.

😭😂🥺🤣❤️✨🙏😍🥰😊

### Shortcodes

Duckquill provides a few useful [shortcodes](https://www.getzola.org/documentation/content/shortcodes/) that simplify some tasks.

#### Alerts

[GitHub-style](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#alerts) alerts. Simply wrap the text of desired alert inside the shortcode to get the desired look.

Available alert types:

- `note`: Useful information that users should know, even when skimming content.
- `tip`: Helpful advice for doing things better or more easily.
- `important`: Key information users need to know to achieve their goal.
- `warning`: Urgent info that needs immediate user attention to avoid problems.
- `caution`: Advises about risks or negative outcomes of certain actions.

```jinja2
{%/* alert(note=true) */%}
-> Alert text <-
{%/* end */%}
```

{% alert(note=true) %}
Useful information that users should know, even when skimming content.
{% end %}

{% alert(tip=true) %}
Helpful advice for doing things better or more easily.
{% end %}

{% alert(important=true) %}
Key information users need to know to achieve their goal.
{% end %}

{% alert(warning=true) %}
Urgent info that needs immediate user attention to avoid problems.
{% end %}

{% alert(caution=true) %}
Advises about risks or negative outcomes of certain actions.
{% end %}

#### Image

By default images come with styling, such as rounded corners and shadow. To fine-tune these, you can use shortcodes with different variable combinations.

Available variables are:

- `url`: URL to an image.
- `url_min`: URL to compressed version of an image, original can be opened by clicking on the image.
- `alt`: Alt text, same as if the text were inside square brackets in Markdown.
- `full`: Forces image to be full-width.
- `full_bleed`: Forces image to fill all the available screen width. Removes shadow, rounded corners and zoom on hover.
- `start`: Float image to the start of paragraph and scale it down.
- `end`: Float image to the end of paragraph and scale it down.
- `pixels`: Uses nearest neighbor algorithm for scaling, useful for keeping pixel-art sharp.
- `transparent`: Removes rounded corners and shadow, useful for transparent images.
- `no_hover`: Removes zoom on hover.

Variables should be comma-separated and be inside the brackets.

```jinja2
{{/* image(url="image.png", alt="This is an image" no_hover=true) */}}
```

{{ image(url="https://i1.theportalwiki.net/img/2/23/Ashpd_blueprint.jpg", alt="Portal Gun blueprint", no_hover=true) }}
<figcaption>Image with an alt text and without zoom on hover</figcaption>

{{ image(url="https://upload.wikimedia.org/wikipedia/commons/b/b4/JPEG_example_JPG_RIP_100.jpg", url_min="https://upload.wikimedia.org/wikipedia/commons/3/38/JPEG_example_JPG_RIP_010.jpg", alt="The gravestone of J.P.G.", no_hover=true) }}
<figcaption>Image with compressed version, an alt text, and without zoom on hover</figcaption>

Alternatively, you can append the following URL anchors. It can be more handy in some cases, e.g such images will render normally in any Markdown editor, opposed to the Zola shortcodes.

- `#full`: Forces image to be full-width.
- `#full-bleed`: Forces image to fill all the available screen width. Removes shadow, rounded corners and zoom on hover.
- `#start`: Float image to the start of paragraph and scale it down.
- `#end`: Float image to the end of paragraph and scale it down.
- `#pixels`: Uses nearest neighbor algorithm for scaling, useful for keeping pixel-art sharp.
- `#transparent`: Removes rounded corners and shadow, useful for transparent images.
- `#no-hover`: Removes zoom on hover.

\
![Toolbx header image](https://containertoolbx.org/assets/toolbx.gif#full#pixels#transparent#no-hover)
<figcaption>Full-width image with an alt text, pixel-art rendering, no shadow and rounded corners, and no zoom on hover</figcaption>

\
![1966 Ford Mustang coupe white](https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/1966_Ford_Mustang_coupe_white_003.jpg/320px-1966_Ford_Mustang_coupe_white_003.jpg#start)
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim aeque doleamus animo, cum corpore dolemus, fieri tamen permagna accessio potest, si aliquod aeternum et infinitum impendere malum nobis opinemur.

\
[![Picture of the magnificent lej da staz just before sunrise in october](https://images.unsplash.com/photo-1635410773896-da585e1fe138?q=80&w=2063&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D#full-bleed)](https://unsplash.com/photos/a-mountain-lake-surrounded-by-trees-and-snow-CqTOTZh5vrs)

#### Video

Same as images, but with a few differences: `no_hover` and `url_min` are not available.

```jinja2
{{/* video(url="video.webm", alt="This is a video") */}}
```

{{ video(url="https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.webm", alt="Red flower wakes up") }}
<figcaption>WebM video example from MDN</figcaption>

#### CRT

Alright, this one doesn't simplify anything, it just adds a CRT-like effect around Markdown code blocks.

```jinja2
{%/* crt() */%}
-> Markdown code block <-
{%/* end */%}
```

{% crt() %}

```
 _____________________________________________
|.'',        Public_Library_Halls         ,''.|
|.'.'',                                 ,''.'.|
|.'.'.'',                             ,''.'.'.|
|.'.'.'.'',                         ,''.'.'.'.|
|.'.'.'.'.|                         |.'.'.'.'.|
|.'.'.'.'.|===;                 ;===|.'.'.'.'.|
|.'.'.'.'.|:::|',             ,'|:::|.'.'.'.'.|
|.'.'.'.'.|---|'.|, _______ ,|.'|---|.'.'.'.'.|
|.'.'.'.'.|:::|'.|'|???????|'|.'|:::|.'.'.'.'.|
|,',',',',|---|',|'|???????|'|,'|---|,',',',',|
|.'.'.'.'.|:::|'.|'|???????|'|.'|:::|.'.'.'.'.|
|.'.'.'.'.|---|','   /%%%\   ','|---|.'.'.'.'.|
|.'.'.'.'.|===:'    /%%%%%\    ':===|.'.'.'.'.|
|.'.'.'.'.|%%%%%%%%%%%%%%%%%%%%%%%%%|.'.'.'.'.|
|.'.'.'.','       /%%%%%%%%%\       ','.'.'.'.|
|.'.'.','        /%%%%%%%%%%%\        ','.'.'.|
|.'.','         /%%%%%%%%%%%%%\         ','.'.|
|.','          /%%%%%%%%%%%%%%%\          ','.|
|;____________/%%%%%Spicer%%%%%%\____________;|
```

{% end %}

{% crt() %}
```
▬▬▬.◙.▬▬▬
═▂▄▄▓▄▄▂
◢◤ █▀▀████▄▄▄◢◤
█▄ █ █▄ ███▀▀▀▀▀▀╬
◥█████◤
══╩══╩═
╬═╬
╬═╬
╬═╬    Just dropped down to say
╬═╬    *add text here*
╬═╬   
╬═╬☻/
╬═╬/▌
╬═╬/  \
```
{% end %}

{% crt() %}
```
───▄▀▀▀▄▄▄▄▄▄▄▀▀▀▄───
───█▒▒░░░░░░░░░▒▒█───
────█░░█░░░░░█░░█────
─▄▄──█░░░▀█▀░░░█──▄▄─
█░░█─▀▄░░░░░░░▄▀─█░░█

```
{% end %}


```
(✿ ͡◕ ᴗ◕)つ━━✫・*。
⊂　　 ノ 　　　・゜+.
しーーＪ　　　°。+ *´¨)
.· ´𝔩𝔢𝔱 𝔱𝔥𝔢𝔯𝔢 𝔟𝔢 𝔠𝔞ᴋ𝔢☆´¨) ¸.·*¨)
(¸.·´ (¸.·’* (¸.·’* (¸.·’* (¸.·’* (¸.·’* *¨)
```

```

▔╲┊┊┊┊┊┊┊┊┊╱▔▏
┊╲┈╲╱▔▔▔▔▔╲╱┈╱
┊┊╲┈╭╮┈┈┈╭╮┈╱┊
┊┊╱┈╰╯┈▂┈╰╯┈╲┊
┊┊▏╭╮▕━┻━▏╭╮▕┊
┊┊╲╰╯┈╲▂╱┈╰╯╱┊
```

```

┊┊┊╱▔▔▔▔▔╲┊┊┊┊┊
┊┊╱┈┈╱▔╲╲╲▏┊┊┊┊
┊╱┈╭━━╱▔▔▔▔╲━━╮
┊▏┈┃▔▔▏╭▅╭▅▕▔▔┃
┊▏┈╰━╱┈╭┳┳╮┳╲━╯
┊╲┈┈╲▏╭━━━━╯▕┊┊
┊┊╲┈┈╲▂▂▂▂▂▂╱▔╲
```

```
┈┈╭━╱▔▔▔▔╲━╮┈┈┈
┈┈╰╱╭▅╮╭▅╮╲╯┈┈┈
╳┈┈▏╰┈▅▅┈╯▕┈┈┈┈
┈┈┈╲┈╰━━╯┈╱┈┈╳┈
┈┈┈╱╱▔╲╱▔╲╲┈┈┈┈
┈╭━╮▔▏┊┊▕▔╭━╮┈╳
┈┃┊┣▔╲┊┊╱▔┫┊┃┈┈
┈╰━━━━╲╱━━━━╯┈╳
```

```


┈┈╱▔▔▔▔▔▔▔▔▔▔▔▏
┈╱╭▏╮╭┻┻╮╭┻┻╮╭▏
▕╮╰▏╯┃╭╮┃┃╭╮┃╰▏
▕╯┈▏┈┗┻┻┛┗┻┻┻╮▏
▕╭╮▏╮┈┈┈┈┏━━━╯▏
▕╰╯▏╯╰┳┳┳┳┳┳╯╭▏
▕┈╭▏╭╮┃┗┛┗┛┃┈╰▏
▕┈╰▏╰╯╰━━━━╯┈┈▏

```

```

░▄░█░░░▄▀▀▀▀▀▄░░░█░▄░
▄▄▀▄░░░█─▀─▀─█░░░▄▀▄▄
░░░░▀▄▒▒▒▒▒▒▒▒▒▄▀░░░░
░░░░░█────▀────█░░░░░
░░░░░█────▀────█░░░░░
```

```

──────▄▌▐▀▀▀▀▀▀▀▀▀▀▀▀▌
───▄▄██▌█░░░░░░░░░░░░▐
▄▄▄▌▐██▌█░░░░░░░░░░░░▐
███████▌█▄▄▄▄▄▄▄▄▄▄▄▄▌
▀❍▀▀▀▀▀▀▀❍❍▀▀▀▀▀▀❍❍▀
```

```
⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⣸⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣾⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⠀⢀⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀
⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣠⣤⣤⣼⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀
⠀⠀⠀⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀
⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀
⠀⠀⠀⠘⣿⣿⣿⣿⠟⠁⠀⠀⠀⠹⣿⣿⣿⣿⣿⠟⠁⠀⠀⠹⣿⣿⣿⠇⠀⠀⠀⠀
⠀⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⢼⣿⠀⢿⣿⣿⣿⣿⠀⣾⣷⠀⠀⢿⣿⣿⣿⠀⠀⠀⠀
⠀⠀⠀⢠⣿⣿⣿⣷⡀⠀⠀⠈⠋⢀⣿⣿⣿⣿⣿⡀⠙⠋⠀⢀⣾⣿⣿⡇⠀⠀⠀⠀
⢀⣀⣀⣀⣿⣿⣿⣿⣿⣶⣶⣶⣶⣿⣿⣿⣿⣾⣿⣷⣦⣤⣴⣿⣿⣿⣿⣤⠤⢤⣤⡄
⠈⠉⠉⢉⣙⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⣀⣀⣀⡀⠀
⠐⠚⠋⠉⢀⣬⡿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣥⣀⡀⠈⠀⠈⠛
⠀⠀⠴⠚⠉⠀⠀⠀⠉⠛⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⠋⠁⠀⠀⠀⠉⠛⠢⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀
```

```
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣤⣴⠶⠶⠾⠛⠛⠛⠷⠶⠶⢶⣦⣄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣶⠾⠛⣫⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢩⣝⡻⢶⣄⡀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣠⣶⢟⡭⣰⡾⠋⠠⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⡀⠀⠈⠻⣦⠙⠿⣦⡄⠀⠀⠀⠀⠀
⠀⠀⠀⠀⢀⣾⠏⡝⣡⣾⡿⡁⠀⠀⠀⢀⡇⠀⠀⠀⡀⠀⠀⢀⠰⠁⠻⣧⡀⠀⠙⣷⡡⣬⡻⣦⠀⠀⠀⠀
⠀⠀⠀⢠⡿⢡⠎⣰⣟⣿⠞⠃⠀⠀⡌⣼⠇⠀⠀⢠⠃⢀⡆⣸⣦⡸⠈⢻⣧⠀⠀⡌⣷⡈⢻⡿⣷⡀⠀⠀
⠀⠀⢠⣿⢣⠇⣼⣿⣿⠃⠀⠀⣀⣀⣵⡿⢀⡀⠀⣸⠰⠀⣆⣾⠚⢿⣆⢪⣿⡄⠀⠱⡼⣇⣾⣇⠼⣷⠀⠀
⠀⠀⣾⠇⠀⣸⣿⡿⡃⠘⠛⠛⣫⡽⣿⣳⠋⠀⡼⢡⠃⠐⣹⡿⣦⣄⣹⣿⢺⣯⠀⠈⠈⣿⠉⢿⣆⢹⣇⠀
⠀⣸⡟⠀⢀⣿⣿⡻⡀⢠⣠⣶⣋⡾⡇⠁⠀⡼⠃⣺⠤⢊⣾⢇⠂⠈⠉⢻⣿⣿⠀⠀⠀⣿⠘⣼⡟⠈⣿⡀
⠀⣿⠳⢀⢸⣿⣯⣤⣵⣿⣿⣶⣟⡻⣷⣠⣜⣁⣰⣿⣤⣼⣣⠊⠀⠀⠀⠈⣿⣿⠀⠀⡀⣿⠀⢿⣆⠀⢻⡇
⠀⣿⠀⠸⢸⠭⣿⠟⠉⠴⡟⠙⠻⣿⣿⣿⡵⠟⢩⣧⢟⣡⣶⣾⣿⣿⣶⣤⣸⣿⠀⠀⠁⣿⢀⣿⣧⠀⢸⡇
⢰⣿⠀⠀⢺⡇⢿⠀⣰⡴⣟⣷⡜⢸⡏⠀⠀⠀⠉⠁⠟⠻⡍⠈⠀⠹⣷⠙⣿⣿⠠⣢⢠⡿⣾⣿⣿⡀⢸⡇
⢸⣿⠀⢀⣼⡇⠀⠀⢻⡟⠴⠫⣄⣼⡇⠀⠀⠀⠀⠀⣶⠴⢻⡿⠆⠀⣿⡇⢘⣿⢛⡅⢸⣧⡈⢹⣷⠇⣸⠇
⠈⣿⠁⣼⠏⠀⠀⢄⠈⠻⠶⡴⠿⠋⠀⠀⠀⠀⠀⠀⢿⣦⠒⠒⢦⣰⡿⠁⢸⣏⡏⣞⡿⠀⣻⠀⣿⣆⣿⠀
⠀⣿⣀⠻⣶⡄⠀⠈⠆⠀⠀⠀⠀⠀⠀⣀⣀⣀⠀⠀⠀⠙⠷⠶⠾⠋⠀⢂⣿⡸⣁⣿⠇⢀⠏⣰⡿⣽⡏⠀
⠀⠹⣿⢠⣿⡿⢶⣤⣀⠀⠀⠀⠀⠀⠘⣯⡛⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⣼⠧⡧⣿⢏⣀⣠⣾⣿⣷⡟⠀⠀
⠀⠀⠹⣷⡏⢿⣦⣿⣿⣻⡶⣦⣤⣄⣀⣈⡛⠋⠀⡀⠀⢀⣀⣀⣤⣶⣿⢏⢢⣿⢻⡟⣻⣿⡟⣿⡟⠁⠀⠀
⠀⠀⠀⠙⠗⠀⠈⠋⠉⠉⠀⠀⠈⠉⠉⠉⠉⠛⠛⠛⠛⠛⠉⠉⢉⣼⢏⣾⢿⣯⣼⡟⠋⠉⠀⠉⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⠿⠛⠁⠀⠈⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀
```

```
⠀⠀⠀⠀⠀⢀⡴⠋⠉⠛⠒⣄⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⢸⠏⠀⠀⣶⡄⠀⠀⣛⠀⠀⠀⠀⠀
⠀⠀⠀⠀⣿⠃⠀⠀⠀⠀⡤⠋⠠⠉⠡⢤⢀⠀
⠀⠀⠀⠀⢿⠀⠀⠀⠀⠀⢉⣝⠲⠤⣄⣀⣀⠌
⠀⠀⠀⠀⡏⠀⠀⠀⠀⠀⢸⠁⠀⠀⠀⠀⠀⠀
⠀⠀⠀⡴⠃⠀⠀⠀⠀⠀⠸⡄⠀⠀⠀⠀⠀⠀
⢀⠖⠋⠀⠀⠀⠀⠀⠀⠀⠀⠘⣆⠀⠀⠀⠀⠀
⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢳⠀
```

```
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡀⠀⣠⡦⠚⠓⢒⠶⡔⠐⠲⣾⣶⠒⠒⢷⡤⡵⠄⡢⢤⣄⣼⠴⠺⣯⣿⣿⡿⢭⣭⣲⣶⡖⠐⠲⡤⣀⡀⢀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡴⠁⠹⡞⡹⣲⢤⣶⣥⣾⣇⠀⢀⣿⣻⡄⢀⣏⣀⣑⣖⣎⠁⢀⣙⡀⢠⠆⢳⡉⠑⢢⠈⠓⣽⣧⢀⣖⢲⣦⡍⠊⠙⡀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡇⠚⢉⢞⡟⡇⣘⠛⣻⢣⣼⣻⢷⠍⠙⢿⣿⡉⣠⣤⣼⣿⣙⠻⡽⢟⠃⠠⠠⣿⡤⢼⣷⣼⣮⡈⢫⢻⣷⣷⠝⠷⣄⢨⡆⢀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢠⠔⠊⠁⢀⠷⠀⠸⣻⡼⡿⢛⡽⡾⢋⠜⢡⠇⠀⠀⠀⠀⠁⠀⡴⠛⠻⣿⣾⡑⠁⠀⠀⢡⣼⠆⢀⠬⡿⡄⠹⡷⠋⠈⡏⢀⣤⢄⠀⠈⠀⡆⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠑⢄⣀⣘⢄⡀⠆⡿⠋⠐⢉⠎⢀⡝⢀⡎⠀⠀⠀⠀⠀⢀⠞⠀⠀⣀⣿⠛⠳⠄⣀⡤⣯⠼⠀⠘⢆⠸⣕⣄⣧⠀⣠⢿⣿⣿⡉⢉⢶⠱⢣⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⣰⡿⠋⣾⡠⢊⠔⠁⠀⠁⢠⠎⢀⡾⠃⠠⡤⡀⠀⢠⠀⠀⠀⡴⢡⠃⠀⠀⠀⠀⣣⠟⡗⠲⠴⠻⣷⣦⡌⣠⣱⡀⠃⣿⢾⣿⣈⠦⡇⠘⢤⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⡠⠷⠤⡺⢋⠜⠁⠀⠀⠀⣠⠇⠀⣼⣁⣤⠞⢇⠈⢡⣃⠄⠀⣼⣰⠃⠀⠀⢀⣴⡺⠛⢱⢁⠀⢀⠀⢹⣏⢻⡃⠀⢻⣤⠏⢾⣾⣈⠒⠁⢀⠏⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣠⣴⣿⡶⠁⠀⠀⠀⠀⣰⠃⠀⡜⠈⠀⠀⠀⠀⠁⠋⠁⠀⡴⢃⣿⣶⣶⣚⣳⠧⠤⣄⣼⢸⠐⠃⠘⣾⡑⡏⠹⢦⢀⡿⠆⠸⡎⣿⡝⢧⣏⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠚⢋⢟⢚⢞⠀⢀⠜⠀⠀⣼⠁⠀⡜⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⣼⣳⠗⠉⠀⠀⠀⠈⢻⡽⡏⣆⣴⡮⢛⠧⣧⠆⠀⠻⠀⠀⠀⠇⠸⣧⣾⣯⠳⡄⠀⠀⠀
⠀⠀⠀⠀⡰⢡⡿⢹⢉⡴⠁⠀⢀⣾⠇⠀⡜⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠂⠀⣿⠿⣷⣤⣶⣶⡶⠶⢾⡿⣛⡽⠿⠒⣇⠀⠀⠑⣔⠀⣀⠠⣼⢧⣸⠋⢼⠋⡦⡹⣆⠀⠀
⢀⣀⡀⣴⢷⡧⠚⣽⡞⠀⠀⠀⣾⡟⢣⣸⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⡞⠀⢸⠏⠀⠈⠻⣧⠀⣀⢔⡿⢿⡇⡇⠀⠀⠈⣧⣀⣠⠋⠈⡁⠀⠀⠙⣿⡶⣆⢀⡽⠈⠋⢇⠀
⠀⠀⠀⢇⡸⣀⡾⡞⠀⠀⠀⡼⡽⡇⢠⡇⠀⡄⠀⠀⠀⠀⠀⠀⠀⢰⠁⣀⣾⣤⣤⡤⠤⣌⣿⣗⣣⡀⣹⠀⠁⠀⠀⠀⣿⡿⣿⡀⠀⣗⣦⣶⣾⠏⣻⣿⣯⠒⠦⢤⡸⡆
⠉⠒⠲⡾⣻⢻⡝⠀⢀⠔⠀⣳⢁⡇⣌⡇⢰⠃⠀⠀⠀⠀⠀⢼⢀⣿⠉⢸⡟⠉⠀⡀⠀⠀⠀⠈⠿⣷⣿⠀⠀⠀⠀⢸⢿⢣⣿⢷⣴⣿⣿⣽⡻⣼⣿⣿⣮⡑⠦⣌⡌⡇
⠀⠀⠀⢻⣇⣾⠁⢠⠎⣸⢐⣿⣾⣷⣹⠀⠸⠞⠛⠇⠀⠀⠀⢸⣼⡇⠀⣼⢇⡤⣶⣿⣾⣿⣿⣶⣤⡈⡗⢀⡄⠀⠀⢸⣿⣮⡛⢤⣿⣿⣿⣿⣷⣿⡟⣿⣿⠽⠓⡦⣍⠂
⠀⠀⡰⠁⠁⡏⢠⠏⠀⠃⡈⠁⡗⣿⢹⡀⡆⣠⣤⣤⣄⠀⠀⢸⣿⡇⠀⣿⡘⣾⣿⠿⣿⣿⣿⡿⣿⣿⣧⡜⡀⠀⠀⢸⣏⣞⣢⡈⣿⣿⣿⢓⣿⣿⣼⣿⠘⢟⣸⠟⠋⠀
⠀⠰⠁⠀⢠⡏⢆⠀⣸⣼⣧⡄⣽⡷⢺⡇⣧⣹⡟⣿⣿⣧⠀⢸⣿⡇⠀⣿⣇⠈⠁⠀⢻⡏⢻⣟⣿⣧⢿⢣⠇⠀⢀⡏⣏⡀⠀⡷⣿⣿⠷⢟⣿⣿⠇⣿⢷⡌⣣⡀⠀⠀
⢀⠇⢠⢀⠏⠀⠈⢆⣇⡿⡏⣷⠟⡇⠀⠇⣧⢹⣧⢻⡾⣻⡇⢸⣷⢣⠀⠹⠻⠀⠀⠀⠀⢻⡥⡴⣿⢋⣆⡞⠀⢠⡺⠀⡏⣸⡰⣡⠏⣤⡀⣸⣿⣹⢹⡿⡘⣿⡷⣧⠀⠀
⠘⠀⢄⡎⠀⣿⠦⢌⣼⠏⢠⠏⢧⣹⠀⣸⡏⠈⢻⣷⢷⣎⡄⠈⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡰⢃⣾⣿⠃⠀⣼⠃⠸⠟⢉⣴⣧⠤⣱⡿⣻⠁⡇⡼⠀⢳⣿⠁⠈⠀⠀
⢸⡀⡼⠀⢠⡜⣆⠸⡏⠀⣾⠀⢀⢈⣟⣉⣷⡀⡈⢿⠀⠁⢡⠺⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢠⣾⣿⠃⠀⣸⢧⣤⣤⡔⣿⢫⣫⣴⠟⠀⡏⣼⢀⣣⢴⠟⢿⡆⠀⠀⠀
⠀⢳⡇⠀⢸⣷⢹⣦⣧⢠⢙⣴⢃⡾⠊⠃⣠⣿⠂⢸⡆⠀⠈⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⣫⡿⢣⣠⣼⡿⠟⠛⢉⢞⡽⣋⡤⢻⣬⡴⡿⣻⢥⣾⠋⠀⢸⣧⠀⠀⠀
⠀⠈⢿⡀⠘⣷⣘⡇⢹⡿⢡⣇⡞⢀⣠⡮⢟⣷⠇⣠⡷⡀⠀⠀⠀⠀⣀⠀⠠⠀⠀⢀⣠⠾⢋⣽⣃⢔⡭⠛⠓⢲⣾⣿⣻⣼⣿⣴⢻⣋⡞⣹⠟⠋⠀⠀⠀⢈⣿⡄⠀⠀
⠀⠀⠀⠉⠒⠚⢿⣿⡃⡟⢾⢸⠉⠉⠓⠂⣩⡯⢾⡟⡓⣈⡢⣄⡀⠀⠀⠀⠀⠀⠈⠉⣀⠴⠋⣁⣴⣿⢶⠶⠶⠟⣿⢿⣿⢛⣟⣡⣿⣿⠟⠁⠀⠀⠀⠀⠀⡼⢈⡇⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠉⠛⣇⠈⠙⠀⠀⠀⠈⢀⡀⠀⠙⠷⠶⣭⣵⣋⣲⣄⣤⠤⠀⠀⣀⣀⡆⠙⠛⣏⡸⠀⠙⢾⡖⠁⠀⠹⣿⣛⡉⠉⠀⠀⠀⠀⠀⠀⠀⣰⠃⢸⠁⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠒⠀⠀⣀⣠⣖⢉⡎⠑⢤⡐⠋⠉⢉⡩⢪⠝⠋⢩⠉⠙⢧⣄⡙⠢⣄⡟⡇⠀⢠⠜⠁⠀⠀⢸⡏⠀⠈⣄⠀⠀⠀⠀⠀⠀⢠⠧⢤⡼⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⡔⠛⠂⢠⣤⡬⠙⢗⠢⣽⠄⣠⠊⠀⠀⠀⠴⠋⠀⠀⠀⠙⣿⣦⡙⢿⣧⣄⣈⠦⣄⠀⢠⣿⠁⠀⠀⢃⣷⠀⠀⠀⠀⠀⠘⡄⠀⡇⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⡎⠖⠂⠒⠼⣄⠀⠙⡄⢸⠋⠀⡷⠁⠀⠀⣠⠂⠀⠀⠀⠀⠀⠀⠸⣷⠙⣮⣿⣿⣿⣿⣷⣿⣾⣅⡀⣀⡠⠜⢓⠄⠀⠀⠀⠀⠀⠈⠾⠁⠀⠀⠀
⠀⠀⠀⠀⡀⠀⠀⠀⢀⣸⢢⢤⠠⡄⠘⣆⣰⡅⣿⠀⡸⠁⠀⠀⡔⠁⠀⠀⠀⠀⠀⠀⠀⠀⢻⣵⠺⣿⣿⣿⡻⣿⠺⣙⢿⣿⣿⡀⣀⣨⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⢄⠀⠀⠀⠈⣆⠀⠀⣸⡇⠀⠀⠀⠘⣴⢯⠏⠛⠉⢰⠃⡀⠀⠜⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⢏⡆⠈⢿⢻⡗⢞⢷⣮⠻⣧⣿⣷⡞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⢘⣦⡀⢀⣠⠜⡀⢀⠃⠀⠀⠀⢣⠀⠈⡏⠀⢠⢞⣇⡾⠃⠀⡜⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⡄⠘⣇⠠⣼⣮⣿⢸⣦⣿⣇⠸⣷⢻⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⢈⣱⣽⡍⠀⣄⢽⡟⠀⠀⠀⢀⣸⡀⠘⢡⠞⣡⣾⡰⠁⠀⠸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣦⣸⡄⢻⣿⣿⡆⢋⢻⢞⢧⠹⣆⣿⣷⡦⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⢈⢻⢺⠊⠈⠀⠳⣀⣠⠞⠁⠀⠱⣴⠇⣾⣅⡿⡱⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠹⡏⡷⣼⣿⠏⣇⡜⠋⣿⣏⢻⣿⣿⢷⢳⠈⢧⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠈⢻⡼⠋⠉⠳⠖⠢⡈⠀⣴⡧⠔⡃⢮⡠⡴⠏⠩⠂⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⡇⠸⣯⣤⡏⠀⢐⡼⢽⣿⣿⣿⣌⡎⡆⠈⡆⠀⠀⠀⠀⠀⠀⠀⠀
⠀⢀⠈⠀⠀⠀⠀⢀⣠⠷⠋⠁⠀⠉⠀⣟⡽⠁⠀⠠⠎⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠀⠀⠀⠀⣁⢀⣿⣿⣷⣰⣮⣾⣽⣿⣿⣹⣿⣇⠙⠀⠃⠀⠀⠀

```



## Captions

Media can have additional text description using the `<figcaption>` HTML tag directly under it.

```markdown
![The Office](https://i.ibb.co/MPDJRsT/ImMAXM3.png)
<figcaption>The image caption</figcaption>
```

![The Office](https://i.ibb.co/MPDJRsT/ImMAXM3.png)
<figcaption>The Office where Stanley works, it has yellow floor and beige walls</figcaption>

## Accordion

<details>
  <summary>I can be a spoiler, I can be a long text, I could be anything.</summary>

_Quack-quack!_

![Cute duck](https://i.ibb.co/x5Wd5dm/EEVSKgV.jpg)

</details>

## Small

<small>Small, cute text that doesn't catch attention.</small>

## Abbreviation

The <abbr title="American Standard Code for Information Interchange">ASCII</abbr> art are awesome!

## Aside

<aside>
Quill and a parchment
<img class="transparent no-hover" style="margin-bottom: 0; border-radius: 0;" alt="Quill and a parchment" src="https://upload.wikimedia.org/wikipedia/commons/thumb/b/b9/%D7%A7%D7%9C%D7%A3%2C_%D7%A0%D7%95%D7%A6%D7%94_%D7%95%D7%93%D7%99%D7%95.jpg/326px-%D7%A7%D7%9C%D7%A3%2C_%D7%A0%D7%95%D7%A6%D7%94_%D7%95%D7%93%D7%99%D7%95.jpg" />
</aside>

A quill is a writing tool made from a moulted flight feather (preferably a primary wing-feather) of a large bird. Quills were used for writing with ink before the invention of the dip pen, the metal-nibbed pen, the fountain pen, and, eventually, the ballpoint pen.

As with the earlier reed pen (and later dip pen), a quill has no internal ink reservoir and therefore needs to periodically be dipped into an inkwell during writing. The hand-cut goose quill is rarely used as a calligraphy tool anymore because many papers are now derived from wood pulp and would quickly wear a quill down. However it is still the tool of choice for a few scribes who have noted that quills provide an unmatched sharp stroke as well as greater flexibility than a steel pen.

## Keyboard shortcut

```html
<kbd>⌘ Super</kbd> + <kbd>Space</kbd>
```

To switch the keyboard layout, press <kbd>⌘ Super</kbd> + <kbd>Space</kbd>.

## Highlighted

You know what? I'm gonna say some <mark>very important</mark> stuff, so <mark>important</mark> that even **bold** is not enough.

## Deleted and Inserted

```html
<del>Text deleted</del> <ins>Text added</ins>
```

<del>Text deleted</del> <ins>Text added</ins>

## Progress bar

```html
<progress value="33" max="100"></progress>
```

<progress value="33" max="100"></progress>

## Sample Output

```html
<samp>Sample Output</samp>
```

<samp>Sample Output</samp>

## Inline Quote

```html
<q>Inline Quote</q>
```

Blah blah <q>Inline Quote</q> hmm.

## Grammar Mistakes

```html
<u>Trying to replicate grammar mistakes</u>
```

<u>Yeet</u> the <u>sus</u> drip while <u>vibing</u> with the <u>TikTok</u> <u>fam</u> on a cap-free boomerang.

## External link

```html
<a class="external" href="https://example.org">Link to site</a>
```

<a class="external" href="https://example.org">Link to site</a>

## Buttons

```html.j2
<div class="dialog-buttons">
  <a class="inline-button" href="#top">Go to Top</a>
  <a class="inline-button colored external" href="{{ config.extra.issues_url }}">File an Issue</a>
</div>
```

> Look at the end of this page xD
