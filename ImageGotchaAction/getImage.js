var MyExtensionJavaScriptClass = function() {};

MyExtensionJavaScriptClass.prototype = {
    run: function(arguments) {
        
        let imgs = getDomImages().concat(...getMetaImages()).concat(...getBingBgImages());
        
        let videos = getAppleShotPhotoWebsiteVideoUrls().concat(...getInsVideoUrls());
        
        arguments.completionFunction({ "imgURLs": imgs, "videoURLs": videos });
    },
    
    finalize: function(arguments) {
        // arguments contains the value the extension provides in [NSExtensionContext completeRequestReturningItems:completion:].
        // In this example, the extension provides a color as a returning item.
        // eval(unescape(arguments["jsCode"]));
    }
};

// The JavaScript file must contain a global object named "ExtensionPreprocessingJS".
var ExtensionPreprocessingJS = new MyExtensionJavaScriptClass;


// MARK: - 获取 URL

// <img> 标签
function getDomImages() {
    const imgUrls = [];
    var imgs = document.getElementsByTagName("img");
    for(var i = 0; i<imgs.length; i++) {
        imgUrls.push(imgs[i].src);
    }
    return imgUrls;
}

// <meta property="og:image" content="" />
function getMetaImages() {
    const imgUrls = [];
    var metaImgs = document.getElementsByTagName("meta");
    for (var i=0; i<metaImgs.length; i++) {
        if (metaImgs[i].getAttribute("property") == "og:image") {
            imgUrls.push(metaImgs[i].content);
        }
    }
    return imgUrls;
}

// bing 的 css background-image
function getBingBgImages() {
    const imgUrls = [];
    var element = document.getElementById("bgDiv");
    if (element instanceof Element) {
        var elementStyle = window.getComputedStyle(element, null);
        var props = elementStyle["backgroundImage"] || elementStyle["background"] || elementStyle["content"];
        var matches = props.match(/(https?:\/\/[^ "'()]*)/);
        if (matches) {
            imgUrls.push(String(matches[1]));
        }
    }
    return imgUrls;
}

// Apple 拍照网站 https://www.apple.com.cn/iphone/photography-how-to/
function getAppleShotPhotoWebsiteVideoUrls() {
    const videoUrls = [];
    var appleVideoElements = document.getElementsByClassName("card-content");
    
    // 这个语法无法执行成功
    // videoUrls = appleVideoElements.map(element => element.href);
    
    for (const item of appleVideoElements) {
        videoUrls.push(item.href)
    }
    // ----OR----
    /*
    for (var i = 0; i < appleVideoElements.length; i++) {
        appleVideoUrls.push(appleVideoElements[i].href);
    }
    */
    return videoUrls;
}

// instagram 的视频地址
function getInsVideoUrls() {
    const videoUrls = [];
    var insVideoElements = document.getElementsByClassName("tWeCl");
    for (var i = 0; i < insVideoElements.length; i++) {
        videoUrls.push(insVideoElements[i].src);
    }
    return videoUrls;
}

// MARK: - querySelectorAll 方式
/*
function uniqueArr(arr) {
    return Array.from(new Set(arr));
}

function getDomImage() {
    let imgList = [].slice.call(document.querySelectorAll('img')).map(item => item.src);
    return imgList;
}

function getStyleImage() {
    const imgList = [];
    let styleEles = [].slice.call(document.querySelectorAll("*[style]"));
    styleEles && styleEles.map(styleEle => {
        const styleStr = Object.entries(styleEle.style).filter(item => item[1]).map(item => item[0] + ':' + item[1]).join(';');
        let styleImages = styleStr.match(/url\((.*)\)/g);
        styleImages = styleImages && styleImages.map(item => item.replace(/url\(['"]*([^'"]*)['"]*\)/,'$1'));
        if(styleImages) imgList.push(...styleImages);
    });
    return imgList;
}

function getCssImage() {
    const styleEles = document.querySelectorAll('style');
    return [].slice.call(styleEles).map(styleEle => {
        const css = styleEle.textContent;
        const cssImages = css.match(/url\((.*)\)/g);
        return cssImages && cssImages.map(item => item.replace(/url\((.*)\)/,'$1')) || [];
    });
}

function getImages() {
    return getDomImage().concat(...getCssImage()).concat(...getStyleImage());
}
*/
