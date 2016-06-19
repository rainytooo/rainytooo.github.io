---
layout: post
title: 在github.io上给jekyll添加分类和标签页
date: 2016-06-19
categories: 
    - writing
    - jekyll
tags: [jekyll, github]
---



花了些时间写了插件支持`jekyll`自动生成category和tag的索引页,并支持分页,push到github上发现悲剧,`github.io`不支持自定义插件.
欲哭无泪,不过也可以理解,毕竟静态页面是github服务器自动生成的,插件是用ruby语言写的,如果有人心存不轨还是很麻烦的.

关于github.io对插件的支持,看看这篇文章[Adding Jekyll plugins to a GitHub Pages site](https://help.github.com/articles/adding-jekyll-plugins-to-a-github-pages-site/)

怎么办?

没办法,那就自己静态化了.参考这个[Separate pages per tag/category with Jekyll (without plugins)](http://christianspecht.de/2014/10/25/separate-pages-per-tag-category-with-jekyll-without-plugins/), 去插件来实现标签和分页.

### 实施步骤


##### 1. 为标签和分类建立2个模板

> `github_category_index.html`

{% raw %}
```html

---
layout: page
---


<div class="posts-list">
  {% for post in site.categories[page.category] %}
  <article class="post-preview">
    <a href="{{ post.url | prepend: site.baseurl }}">
      <h2 class="post-title">{{ post.title }}</h2>
    
      {% if post.subtitle %}
      <h3 class="post-subtitle">
        {{ post.subtitle }}
      </h3>
      {% endif %}  
    </a>

    <p class="post-meta">
      <!-- Posted on {{ post.date | date: "%B %-d, %Y" }} -->
      Posted on {{ post.date | date: "%Y-%m-%d" }}
    </p>
  
    <div class="post-entry">
      {{ post.content | truncatewords: 20 | strip_html | xml_escape}}
      <a href="{{ post.url | prepend: site.baseurl }}" class="post-read-more">[Read&nbsp;More]</a>
    </div>
  
   </article>
  {% endfor %}
</div>

```
{% endraw %}

> `github_tag_index.html`


{% raw %}
```html
---
layout: page
---

<div class="posts-list">
  {% for post in site.tags[page.tag] %}
  <article class="post-preview">
    <a href="{{ post.url | prepend: site.baseurl }}">
      <h2 class="post-title">{{ post.title }}</h2>
    
      {% if post.subtitle %}
      <h3 class="post-subtitle">
        {{ post.subtitle }}
      </h3>
      {% endif %}  
    </a>

    <p class="post-meta">
      <!-- Posted on {{ post.date | date: "%B %-d, %Y" }} -->
      Posted on {{ post.date | date: "%Y-%m-%d" }}
    </p>
  
    <div class="post-entry">
      {{ post.content | truncatewords: 20 | strip_html | xml_escape}}
      <a href="{{ post.url | prepend: site.baseurl }}" class="post-read-more">[Read&nbsp;More]</a>
    </div>
  
   </article>
  {% endfor %}
</div>
```
{% endraw %}

##### 2. 在根目录下为某个标签或者分类建立

以jekyll这个分类为例,在根目录下建立文件

```
--s
    |--cate
    |   |--writing
    |   |   |--jekyll
    |   |   |   |--index.html
```

内容很简单

```
---
layout: github_category_index
category: jekyll
---
```

重新build

`jekyll build --trace `

这样就能在`http://127.0.0.1:4000/s/cate/writing/jekyll/`查看此分类的文章列表了


### 优点

* 目录完全自定义
* 无需任何插件

### 缺点

* 每个标签要手动添加一个索引页
* 无法分页
