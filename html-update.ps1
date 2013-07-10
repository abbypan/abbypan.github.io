
Get-ChildItem -Filter '*.t2t'| Foreach-Object {  t2t -t html $_.fullname  }
