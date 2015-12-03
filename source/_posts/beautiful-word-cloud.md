title: 简单美观的文字标签云组件
categories: 前端
tags:
  - javascript
  - WordCloud

date: 2015-12-03 22:10:40
---
 
 

# 简单美观的文字标签云组件

  </header>

  <div class="entry">

经常在微博或微信的文章中看到漂亮的分析图。我认为在大数据的时代，目前最关键的就是如何让非专业人员轻松的进行数据分析，比如可以象使用office一样制作信息图（infographic），而不是用专业的制图工具。这一步跨过去，看到的将是欣欣向荣的真正大数据时代。

而这之前，首先缺少的就是，可以让普通开发人员使用的大数据时代的可视化图表组件，比如标签云图，所幸，业界已经有[ECharts](http://github.com/ecomfe/echarts)和[WordCloud](http://github.com/timdream/wordcloud)这两大利器，本文只介绍后者。

![中文](http://bruce.u.qiniudn.com/2014/02/10/wordcloud-cn.jpg)

<a id="more"></a>

首先页面必须是html5编写。
<figure class="highlight xml"><table><tr><td class="code"><pre><span class="line"><span class="doctype">&lt;!DOCTYPE html&gt;</span></span>
<span class="line"><span class="tag">&lt;<span class="title">html</span>&gt;</span></span>
<span class="line"> <span class="tag">&lt;<span class="title">head</span>&gt;</span></span>
<span class="line">  <span class="tag">&lt;<span class="title">meta</span> <span class="attribute">charset</span>=<span class="value">"UTF-8"</span>&gt;</span></span>
<span class="line">  <span class="tag">&lt;<span class="title">title</span>&gt;</span><span class="tag">&lt;/<span class="title">title</span>&gt;</span></span>
<span class="line"> <span class="tag">&lt;/<span class="title">head</span>&gt;</span></span>
<span class="line"> <span class="tag">&lt;<span class="title">body</span>&gt;</span>	</span>
<span class="line"> <span class="tag">&lt;/<span class="title">body</span>&gt;</span></span>
<span class="line"><span class="tag">&lt;/<span class="title">html</span>&gt;</span></span>
</pre></td></tr></table></figure>

引入[jQuery](http://jquery.com/)和[WordCloud2.js](http://github.com/timdream/wordcloud2.js)。

<figure class="highlight xml"><table><tr><td class="code"><pre><span class="line"><span class="tag">&lt;<span class="title">script</span> <span class="attribute">src</span>=<span class="value">"src/wordcloud2.js"</span>&gt;</span><span class="undefined"></span><span class="tag">&lt;/<span class="title">script</span>&gt;</span></span>
<span class="line"><span class="tag">&lt;<span class="title">script</span> <span class="attribute">src</span>=<span class="value">"//ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"</span>&gt;</span><span class="undefined"></span><span class="tag">&lt;/<span class="title">script</span>&gt;</span></span>
</pre></td></tr></table></figure>

定义canvas容器。

<figure class="highlight stylus"><table><tr><td class="code"><pre><span class="line">&lt;<span class="tag">div</span> id=<span class="string">"canvas-container"</span> align=<span class="string">"center"</span>&gt;</span>
<span class="line"> &lt;<span class="tag">canvas</span> id=<span class="string">"canvas"</span> <span class="attribute">width</span>=<span class="string">"800px"</span> <span class="attribute">height</span>=<span class="string">"600px"</span>&gt;&lt;/canvas&gt;</span>
<span class="line">&lt;/div&gt;</span>
</pre></td></tr></table></figure>

绘图。

<figure class="highlight xml"><table><tr><td class="code"><pre><span class="line"><span class="tag">&lt;<span class="title">script</span>&gt;</span><span class="prolog"> </span>
<span class="line"><span class="atom">var</span> <span class="atom">options</span> = <span class="atom">eval</span>(&#123;</span>
<span class="line">  <span class="string">"list"</span>: [[<span class="string">'傻猎豹'</span>, <span class="number">10</span>], [<span class="string">'不如'</span>, <span class="number">9</span>], [<span class="string">'麻花疼'</span>, <span class="number">7</span>], [<span class="string">'麻云'</span>, <span class="number">6</span>],[<span class="string">'李眼红'</span>, <span class="number">4</span>], [<span class="string">'雷布斯'</span>, <span class="number">5</span>],[<span class="string">'周红衣'</span>, <span class="number">4</span>],[<span class="string">'刘墙洞'</span>, <span class="number">3</span>],[<span class="string">'李国情'</span>, <span class="number">3</span>]],</span>
<span class="line">  <span class="string">"gridSize"</span>: <span class="number">8</span>,</span>
<span class="line">  <span class="string">"weightFactor"</span>: <span class="number">16</span>,</span>
<span class="line">  <span class="string">"fontFamily"</span>: <span class="string">'Hiragino Mincho Pro, serif'</span>,</span>
<span class="line">  <span class="string">"color"</span>: <span class="string">'random-dark'</span>,</span>
<span class="line">  <span class="string">"backgroundColor"</span>: <span class="string">'#f0f0f0'</span>,</span>
<span class="line">  <span class="string">"rotateRatio"</span>: <span class="number">0</span></span>
<span class="line">&#125;);</span>
<span class="line"></span>
<span class="line"><span class="atom">var</span> <span class="atom">canvas</span> = <span class="atom">document</span>.<span class="atom">getElementById</span>(<span class="string">'canvas'</span>);</span>
<span class="line"></span>
<span class="line"><span class="name">WordCloud</span>(<span class="atom">canvas</span>, <span class="atom">options</span>);</span>
<span class="line"></span><span class="tag">&lt;/<span class="title">script</span>&gt;</span></span>
</pre></td></tr></table></figure>
> 至此，全部完毕。执行页面，美丽的云图便展现在你面前，具体的API可以参考[这里](http://github.com/timdream/wordcloud2.js/blob/master/API.md)。

下面举个英文的例子，为了美观稍微改变一下参数：

<figure class="highlight prolog"><table><tr><td class="code"><pre><span class="line"><span class="string">"list"</span>: [[<span class="string">'bruce-sha'</span>, <span class="number">10</span>], [<span class="string">'buru'</span>, <span class="number">9</span>], [<span class="string">'tencent'</span>, <span class="number">7</span>], [<span class="string">'alibaba'</span>, <span class="number">6</span>], [<span class="string">'baidu'</span>, <span class="number">4</span>], [<span class="string">'xiaomi'</span>, <span class="number">5</span>],[<span class="string">'360'</span>, <span class="number">4</span>],[<span class="string">'jingdong'</span>, <span class="number">3</span>],[<span class="string">'dangdang'</span>, <span class="number">3</span>],[<span class="string">'ibruce.info'</span>, <span class="number">1</span>]],</span>
<span class="line"><span class="string">"gridSize"</span>: <span class="number">16</span>,</span>
<span class="line"><span class="string">"weightFactor"</span>: <span class="number">16</span>,</span>
<span class="line"><span class="string">"fontFamily"</span>: <span class="string">'Times, serif'</span>,</span>
<span class="line"><span class="string">"color"</span>: <span class="string">'random-light'</span>,</span>
<span class="line"><span class="string">"backgroundColor"</span>: <span class="string">'#333'</span>,</span>
<span class="line"><span class="string">"rotateRatio"</span>: <span class="number">0</span></span>
</pre></td></tr></table></figure>

![英文](http://bruce.u.qiniudn.com/2014/02/10/wordcloud-en.jpg)
