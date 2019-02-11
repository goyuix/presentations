# Remember: Office must be installed wherever this script is run

$date = get-date -format MM-dd-yyyy

$word = New-Object -ComObject word.application
$word.visible = $true
$doc = $word.documents.add()

$selection = $word.selection
$selection.WholeStory()

$selection.font.size = 14
$selection.font.bold = 1
$selection.typeText("My Document: SharePoint Saturday Utah 2019")

$selection.TypeParagraph()
$selection.font.size = 11
$selection.typeText("Date: $date")
