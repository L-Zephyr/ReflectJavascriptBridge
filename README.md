# ReflectJavascriptBridge
ReflectJavascriptBridge是一个用于Native与JavaScript通信的iOS库，支持UIWebView和WKWebView。  

### 为什么用ReflectJavascriptBridge
自从iOS7以来我们可以通过JavaScriptCore框架直接将Native的对象传递给JavaScript使用，这是一个非常方便的功能，但是在UIWebView和WKWebView中并没有提供公开的API来获取JSContext对象(可以通过一些比较trick的方法来获取，但有被拒风险)。  

为了解决这个问题，ReflectJavascriptBridge使用合法的方式实现了类似JavaScriptCore的通讯方式，将Native代码中创建的对象桥接到JS环境中。

### 接入代码
- import头文件`ReflectJavascriptBridge.h`

- 将下面这段JS代码拷贝到你的前端代码中:
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

- 根据WebView创建一个`ReflectJavascriptBridge`实例，支持`UIWebView`和`WKWebView`，随后的操作都在`_bridge`对象上完成
```objective-c
_bridge = [ReflectJavascriptBridge bridge:_webView delegate:self];
```

### ReflectJavascriptBridge

使用`ReflectJavascriptBridge`对象，通过下标语法将原生的对象桥接到JavaScript中，在前端代码中可以直接访问原生对象的方法。

#### 将原生对象桥接到JavaScript中

说先自定义定义一个协议继承自`ReflectBridgeExport`，在这个协议中声明需要暴露给JavaScript的方法，然后在你的类中实现这个协议：

```objective-c
// 定义一个继承自ReflectBridgeExport的协议
@protocol NativeExport <ReflectBridgeExport>
- (int)add:(int)a b:(int)b; // 这是需要暴露给JavaScript的方法
@end
  
// 自定义一个遵守NativeExport的类，并提供add:b的实现
@interface MyClass: NSObject <NativeExport>
...
@end
```

之后，`MyClass`类型的对象就可以通过`_bridge`对象的下标语法桥接到WebView的JavaScript环境中了：

```objective-c
MyClass *obj = [[MyClass alloc] init];
_bridge[@"native"] = obj;
```

*注意：*ReflectJavascriptBridge*对象中会保留一份obj的强引用，当心出现循环引用而导致内存泄露*

在前端代码中可以通过`ReflectJavascriptBridge`来访问该对象：

```javascript
ReflectJavascriptBridge.native.addB(num1, num2);
```

需要注意的是，默认情况下将Objective-C中的方法名的各个部分拼接在一起，参数名的首字母大写并移除冒号，作为转换后的JavaScript方法名，如上面原生方法的`add:b`在转换后变成了`addB`。

通过`JSExportAs`宏可以自定义JavaScript中的方法名，在自定义的协议中通过`JSExportAs`声明方法，并提供自定义的方法名：

```objective-c
@protocol NativeExport <ReflectBridgeExport>
JSExportAs(add, - (int)add:(int)a b:(int)b); // 将JavaScript中的方法命名为add
@end
```

这样在JavaScript中就可以通过方法名`add`来调用原生代码中的`add:b`方法了：

```javascript
ReflectJavascriptBridge.native.add(num1, num2);
```

#### 将Block桥接到JavaScript中

除了遵循`ReflectBridgeExport`协议的原生对象之外，还可以将Objective-C中Block桥接到JavaScript中：

```objective-c
_bridge[@"blockname"] = ^(NSString *str1, NSString *str2) {
    // do something..
	return [str1 stringByAppendingString:str2];
};
```

在JavaScript中通过可以通过`blockname`来执行这个闭包：

```javascript
ReflectJavascriptBridge.blockname(str1, str2);
```

#### 参数类型

在JavaScript调用本地方法时，所支持的参数类型有：

1. 整型
2. 浮点型（单精度和双精度）
3. NSNumber
4. NSString
5. RJBCallback类型的闭包
6. NSArray（数组中不能包含闭包类型对象）
7. NSDictionary（字典中不能包含闭包类型对象）

#### 返回值

如果调用的原生方法有返回值，在JavaScript中可以通过在参数列表之后提供一个闭包来接收返回值：

```javascript
ReflectJavascriptBridge.native.add(num1, num2, function(ret) {
  // 获取原生方法的返回值ret
});
```

还是上面的那个例子，add方法有两个参数：num1和num2，并且有int类型的返回值，JavaScript在调用该方法时可以在参数列表后面提供一个闭包，方法返回时会将返回值作为参数执行该闭包，如果没有提供该闭包则返回值会被忽略。