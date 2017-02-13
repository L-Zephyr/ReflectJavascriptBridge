# ReflectJavascriptBridge
ReflectJavascriptBridge是一个用于Native与JavaScript通信的iOS库，支持UIWebView和WKWebView。  

## 为什么用ReflectJavascriptBridge
自从iOS7以来我们可以通过JavaScriptCore框架直接将Native的对象传递给JavaScript使用，这是一个非常方便的功能，但是在UIWebView和WKWebView中并没有提供公开的API来获取JSContext对象(UIWebView可以通过一些trick的方法来获取，但有被拒风险)。  

为了解决这个问题，ReflectJavascriptBridge使用合法的方式实现了类似JavaScriptCore的通讯方式，将Native代码中创建的对象桥接到JS环境中。

## 使用
- import头文件`ReflectJavascriptBridge.h`

- 将下面这段代码拷贝到你的JS代码中:
```javascript
;(function() {
  if (window.ReflectJavascriptBridge) {
    return;
  }
  console.log(document);
  var iFrame = document.createElement("iframe");
  iFrame.style.display = 'none';
  iFrame.src = "ReflectJavascriptBridge://_InjectJs_";
  document.documentElement.appendChild(iFrame);
  setTimeout(function() {
    document.documentElement.removeChild(iFrame);
  }, 0);
})();

function reflectJavascriptBridgeRegisterFunction(name, func) {
  if (window.ReflectJavascriptBridge) {
    window.ReflectJavascriptBridge[name] = func;
  } else if (window.RJBRegisteredFunctions) {
    window.RJBRegisteredFunctions.push({name: name, func: func});
  } else {
    window.RJBRegisteredFunctions = [{name: name, func: func}];
  }
}
```

- 根据webView创建`ReflectJavascriptBridge`实例，支持`UIWebView`和`WKWebView`
```objective-c
_bridge = [ReflectJavascriptBridge bridge:_webView delegate:self];
```

- 类似`JavascriptCore`中的`JSExport`，你需要定义一个协议继承自`ReflectBridgeExport`，在这个协议中声明需要bridge到js的方法和属性，然后在你的类中实现这个协议，这个类的实例就可以被桥接到js中了

- 如下，obj为该类的一个实例，使用下标语法将obj传递给js并命名为nativeObject
```
_bridge[@"nativeObject"] = obj;
```
之后在js中就可以直接使用nativeObject中的方法了
```javascript
ReflectJavascriptBridge.nativeObject.xxxx(num1, num2);
```
协议中声明的属性将被转换成相应的`setter`和`getter`方法  
**注意**: _bridge对象中会保留一份obj的强引用，当心出现循环引用而导致内存泄露

- 如果native对象的方法有返回值，在js中调用该方法时可以通过闭包的方法来接收返回值，具体的做法是在方法参数的最后加上一个闭包用于接收返回值
```javascript
ReflectJavascriptBridge.nativeObject.xxxx(num1, num2, function(retValue) {
	// do something with retValue
})
```

- 在将native方法转换成js方法时，所采用的转换规则与`JavascriptCore`中相同，即将方法参数以首字母大写的方法拼装起来作为js方法，如:`add:b:`将被装换成`addB`.  

同样的，你也可以通过宏`JSExportAs`将其重命名: 
```objective-c
JSExportAs(add, - (NSInteger)add:(NSInteger)a b:(NSInteger)b); // 添加在协议中，将add:b:命名为add
```

- 目前方法参数支持的类型有：整型、浮点型、NSNumber、NSString

##TODO
1. 支持直接将block传递给js
2. ...