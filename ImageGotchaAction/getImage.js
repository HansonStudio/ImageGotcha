var MyExtensionJavaScriptClass = function() {};

MyExtensionJavaScriptClass.prototype = {
    run: function(arguments) {
        // <img> 标签
        var imgs = document.getElementsByTagName("img");
        var imgUrls = new Array();
        for(var i = 0; i<imgs.length; i++) {
            imgUrls.push(imgs[i].src);
        }
        
        // <meta property="og:image" content="" />
        var metaImgs = document.getElementsByTagName("meta");
        for (var i=0; i<metaImgs.length; i++) {
            if (metaImgs[i].getAttribute("property") == "og:image") {
                imgUrls.push(metaImgs[i].content);
            }
        }
        
        // bing 的 css background-image
        var element = document.getElementById("bgDiv");
        if (element instanceof Element) {
            var elementStyle = window.getComputedStyle(element, null);
            var props = elementStyle["backgroundImage"] || elementStyle["background"] || elementStyle["content"];
            var matches = props.match(/(https?:\/\/[^ "'()]*)/);
            if (matches) {
                imgUrls.push(String(matches[1]));
            }
        }
        
        // instagram的视频地址
        var insVideoElements = document.getElementsByClassName("tWeCl");
        var insVideoUrls = new Array();
        for (var i = 0; i < insVideoElements.length; i++) {
            insVideoUrls.push(insVideoElements[i].src);
        }
        
        arguments.completionFunction({"imgURLs": imgUrls, "insVideoUrls": insVideoUrls});
    },
    
    finalize: function(arguments) {
        // arguments contains the value the extension provides in [NSExtensionContext completeRequestReturningItems:completion:].
        // In this example, the extension provides a color as a returning item.
        // eval(unescape(arguments["jsCode"]));
    }
};

// The JavaScript file must contain a global object named "ExtensionPreprocessingJS".
var ExtensionPreprocessingJS = new MyExtensionJavaScriptClass;
