
Get-ChildItem -Filter '*.t2t'| Foreach-Object {  txt2tags -t html $_.fullname  }
