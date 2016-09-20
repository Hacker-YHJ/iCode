require '../stylus/main'
domready = require 'domready'
punctuationize = require './_punctuationize'
domtoimage = require 'dom-to-image'
firebase = require 'firebase'
extToLang = require './_extToLang'

FIREBASE_CONFIG =
  apiKey: 'AIzaSyBDdcex1yD9PgVg1V7z4B20kvEewahTU54'
  authDomain: 'icodepic.firebaseapp.com'
  storageBucket: 'firebase-icodepic.appspot.com'
firebase.initializeApp FIREBASE_CONFIG
storageRef = firebase.storage().ref()

$id = document.getElementById.bind document
$tag = document.getElementsByTagName.bind document
$main = null
$txtYear = null
$txtMonth = null
$txtDay = null
$btnQuestion = null
$btnUpload = null
$btnDownload = null
$btnFColor = null
$btnBColor = null
$btnFBShare = null
$inputFColor = null
$inputBColor = null
$inputFile = null
$code = null
$control = null
$bio = null
$name = null
$lang = null

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
  $btnQuestion = $id 'btnQuestion'
  $btnUpload = $id 'btnUpload'
  $btnDownload = $id 'btnDownload'
  $btnFColor = $id 'btnFColor'
  $btnBColor = $id 'btnBColor'
  $btnFBShare = $id 'btnFBShare'
  $inputFile = $id 'inputFile'
  $inputFColor = $id 'inputFColor'
  $inputBColor = $id 'inputBColor'
  $control = document.querySelector '.control'
  $bio = document.querySelector '.bio'
  [$name, $lang] = document.querySelectorAll 'span'

  setTimeout( ->
    $bio.classList.add 'active'
    $control.classList.add 'active'
  , 2000)

  setTimeout( ->
    $bio.classList.remove 'active'
    $control.classList.remove 'active'
  , 6000)

  $code = $tag('code')[0]

  t = new Date()
  $txtYear.textContent = t.getFullYear()
  $txtMonth.textContent = t.getMonth() + 1
  $txtDay.textContent = t.getDate()

  onFColorClick = $inputFColor.click.bind($inputFColor)
  onBColorClick = $inputBColor.click.bind($inputBColor)
  onUploadClick = $inputFile.click.bind($inputFile)

  $btnQuestion.addEventListener 'click', onQuestionClick
  $btnUpload.addEventListener 'click', onUploadClick
  $btnDownload.addEventListener 'click', onDownloadClick
  $btnFColor.addEventListener 'click', onFColorClick
  $btnBColor.addEventListener 'click', onBColorClick
  $btnFBShare.addEventListener 'click', onFBShareClick
  $inputFile.addEventListener 'change', onInputChange
  $inputFColor.addEventListener 'change', onInputFColorChange
  $inputBColor.addEventListener 'change', onInputBColorChange

  $btns = document.querySelectorAll('.btn')
  [].forEach.call $btns, (elem) ->
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

createImgConfig = ->
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

onQuestionClick = ->
  $bio.classList.toggle 'active'
  $control.classList.toggle 'active'

onDownloadClick = ->
  config = createImgConfig()
  domtoimage.toPng($main, config).then (dataUrl) ->
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
    idx = file.name.lastIndexOf('.')

    if idx isnt -1
      ext = file.name[idx + 1..-1]
      lang = extToLang ext
      if lang.length > 0
        $lang.textContent = lang

  reader.readAsText(file)

onInputFColorChange = (e) ->
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
  picRef = storageRef.child "#{$name.textContent}-#{$lang.textContent}-#{Date.now()}.png"
  config = createImgConfig()
  domtoimage.toBlob($main, config)
  .then (blob) ->
    picRef.put blob
  .then (snapshot) ->
    picRef.getDownloadURL()
  .then (url) ->
    fbShareConfig =
      method: 'feed'
      link: 'http://thomas-yang.me/projects/iCode'
      picture: url
      name: 'Minimalist poster for my source code.'
      caption: 'iCode'
      description: "I am #{$name.textContent}. I write #{$lang.textContent}."
    FB.ui fbShareConfig, (res) ->
      # TODO
      # thanks for sharing
      res
  .catch (err) -> throw err
