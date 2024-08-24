rxbreach模式使用功能如下:<br>
```net.Receive("RoundStart", function(len)```中添加```net.Start("RoundStart"),net.SendToServer()```<br>
```net.Receive("PostStart", function(len)```中添加```net.Start("PostStart"),net.SendToServer()```
