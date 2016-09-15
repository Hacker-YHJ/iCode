require '../stylus/main'
domready = require 'domready'
punctuationize = require 'punctuationize'
domtoimage = require 'dom-to-image'

$id = document.getElementById.bind document
$tag = document.getElementsByTagName.bind document
$main = null
$txtYear = null
$txtMonth = null
$txtDay = null
$btnUpload = null
$btnDownload = null
$btnFColor = null
$btnBColor = null
$btnFBShare = null
$inputFColor = null
$inputBColor = null
$inputFile = null
$code = null
ratio = 1.413684211
zSpace = '&#8203;'
zNonBreakSpace = '&#8288;'
mainWidth = null
mainHeight = null

domready ->
  $main = $tag('main')[0]
  $txtYear = $id 'txtYear'
  $txtMonth = $id 'txtMonth'
  $txtDay = $id 'txtDay'
  $btnUpload = $id 'btnUpload'
  $btnDownload = $id 'btnDownload'
  $btnFColor = $id 'btnFColor'
  $btnBColor = $id 'btnBColor'
  $btnFBShare = $id 'btnFBShare'
  $inputFile = $id 'inputFile'
  $inputFColor = $id 'inputFColor'
  $inputBColor = $id 'inputBColor'

  $code = $tag('code')[0]

  t = new Date()
  $txtYear.textContent = t.getFullYear()
  $txtMonth.textContent = t.getMonth() + 1
  $txtDay.textContent = t.getDate()

  onFColorClick = $inputFColor.click.bind($inputFColor)
  onBColorClick = $inputBColor.click.bind($inputBColor)
  onUploadClick = $inputFile.click.bind($inputFile)

  $btnUpload.addEventListener 'click', onUploadClick
  $btnDownload.addEventListener 'click', onDownloadClick
  $btnFColor.addEventListener 'click', onFColorClick
  $btnBColor.addEventListener 'click', onBColorClick
  $btnFBShare.addEventListener 'click', onFBShareClick
  $inputFile.addEventListener 'change', onInputChange
  $inputFColor.addEventListener 'change', onInputFColorChange
  $inputBColor.addEventListener 'change', onInputBColorChange

  document.querySelectorAll('.btn').forEach (elem) ->
    elem.addEventListener 'mouseenter', onBtnMouseEnter
    elem.addEventListener 'mouseleave', onBtnMouseLeave

  window.addEventListener 'resize', onResize
  onResize()

onResize = ->
  if window.innerHeight / window.innerWidth > ratio
    mainHeight = window.innerWidth * ratio * .95
    mainWidth = window.innerWidth * .95
    $main.style.fontSize = "#{.95 * ratio}vw"
  else
    mainHeight = window.innerHeight * .95
    mainWidth = window.innerHeight / ratio * .95
    $main.style.fontSize = '0.95vh'
  $main.style.height = "#{mainHeight}px"
  $main.style.width = "#{mainWidth}px"

createImg = ->
  config =
    filter: (node) ->
      !node?.classList?.contains('no-print')
    height: 2 * mainHeight
    width: 2 * mainWidth
    style:
      position: 'absolute'
      margin: 0
      top: '50%'
      left: '50%'
      transform: 'translate(-25%, -25%) scale(2)'
      webkitFontSmoothing: 'subpixel-antialiased'

  domtoimage.toPng $main, config

onDownloadClick = ->
  createImg().then (dataUrl) ->
    link = document.createElement 'a'
    link.download = 'iCode-poster.png'
    link.href = dataUrl
    link.click()
  .catch (err) -> throw err

onInputChange = (input) ->
  file = input.target.files[0]
  return unless file

  reader = new FileReader()
  reader.onload = (e) ->
    contents = e.target.result
    str = punctuationize contents, { space: 'none' }
    while str.length < 100
      str = str + str
    if str.length > 100
      rmd = ~~(Math.random() * (str.length - 100))
      str = str[rmd...rmd + 100]
    nstr = []
    for i in [0...10]
      nstr.push str[i * 10...(i + 1) * 10].split('').join(zNonBreakSpace)
    nstr = nstr.join zSpace
    $code.innerHTML = nstr

  reader.readAsText(file)

onInputFColorChange = (e) ->
  console.log e.target.value
  $main.style.color = e.target.value

onInputBColorChange = (e) ->
  $main.style.backgroundColor = e.target.value

onBtnMouseEnter = ->
  @style.color = $main.style.backgroundColor
  @style.backgroundColor = $main.style.color

onBtnMouseLeave = ->
  @style.removeProperty 'color'
  @style.removeProperty 'background-color'

onFBShareClick = ->
  createImg().then (dataUrl) ->
    config =
      method: 'share'
      href: 'http://thomas-yang.me/projects/iCode'
    FB.ui config, (res) ->
      console.log res
  .catch (err) -> throw err
