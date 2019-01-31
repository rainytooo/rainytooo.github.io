---
layout: post
title: django从1.11升级到2.1.5
subtitle: 升级开发环境的时候把python从2.7升级到了3.7,同时把django从1.11直接升级到了2.1.5
date: 2019-01-31
category: [language, python]
tags: [django]
published: true
---

昨天升级系统和开发环境,从zsh vim 到mysql, 从ruby 到java 到python,从sublime到pycharm,xcode,从jenkins到docker,nexus, 几乎所有在用的开发环境,编辑器,系统包,软件包,框架等等全部升级了一遍, 几乎所有在用的全部没有放过,连带的把生产环境也一起升级,所以包括docker的镜像也全部从新编译.

这一顿操作用了我足足两天时间.搞干净了好过年哈!


项目用的比较多的就是django了,之前一直是`python2.7 +django1.11`(好像是去年升级到django1.11的), 今天一咬牙直接把升级`python 3.7.2`, `django2.1.5`,于是就有非常多的痛苦的事情了.

拿重要的说吧

---

## 1.配置文件

### (1).中间件配置

原来的

```
MIDDLEWARE_CLASSES = (
...
)
```

改成

```
MIDDLEWARE = (
...
)
```

### (2).SessionAuthenticationMiddleware不再支持
直接注释掉
```
    # 'django.contrib.auth.middleware.SessionAuthenticationMiddleware', remove from django2
```

### (3).AUTHENTICATION_BACKENDS的配置从tuple变成array

我不记得是不是必要的了
```
AUTHENTICATION_BACKENDS = (
    ...
)
```
改成

```python
AUTHENTICATION_BACKENDS = [
    ...
]
```

### (4).djangorestframework的配置(非必要,如果没有使用的话)

```
    'DEFAULT_FILTER_BACKENDS': ('rest_framework.filters.DjangoFilterBackend',
                                'rest_framework.filters.OrderingFilter'),

```

改为

```
    'DEFAULT_FILTER_BACKENDS': ('django_filters.rest_framework.DjangoFilterBackend',
                                'django_filters.rest_framework.OrderingFilter'),
```

oauth相关的DEFAULT_PERMISSION_CLASSES,下面这些好像都用不了了

```
        # 'oauth2_provider.contrib.rest_framework.IsAuthenticatedOrTokenHasScope',
        # 'rest_framework.permissions.TokenAuthentication',
        # 'rest_framework.permissions.IsAuthenticatedOrReadOnly',
        # 读写都必须经过认证
        # 'rest_framework.permissions.IsAuthenticated',
```
改成
```
'DEFAULT_PERMISSION_CLASSES': (
        'oauth2_provider.contrib.rest_framework.TokenHasReadWriteScope',
)
```
---

## 2.django的辅助类变更

### (1).url里的include

现在要从`django.url`来import include, 过去是`django.conf.url`

### (2).url里添加`app_name`

如果在urls.py里使用了`namespace`, 那么请在相应的urls文件的前面添加`app_name`

```
    # 视频
    url(r'^videos/', include('applications.videos.urls', namespace='videos')),
```
那么要在`applications.videos.urls`里添加

```
app_name = 'videos'
```
如果不这样就会报如下错误

```
   'Specifying a namespace in include() without providing an app_name '
django.core.exceptions.ImproperlyConfigured: Specifying a namespace in include() without providing an app_name is not supported. Set the app_name attribute in the included module, or pass a 2-tuple containing the list of patterns and app_name instead.
```

### (3).如果自己实现了AUTHENTICATION_BACKENDS

那么`authenticate`方法做如下变化

```
    def authenticate(self, username=None, password=None):
```
改为

```
    def authenticate(self, request, username=None, password=None, **kwars):
```

### (4) reverse移动了位置

```
from django.core.urlresolvers import reverse
```

改为

```
from django.urls import reverse
```

### (5).django.contrib.auth里的视图做了变更

如果使用django auth里的login logout等视图,那么在url里原来你是这么写

```
from django.contrib.auth import views as django_auth_view

    url(r'^logout/$', django_auth_view.logout,

```

现在改成

```
    url(r'^logout/$', django_auth_view.LogoutView.as_view(),

```

另外如果使用了自定义模板,原来你是这么写的

```
    url(r'^login/$',
        auth_views.login,
        {'template_name': 'registration/v2/login.html'},
        name='login'),

```
现在要改成

```
     url(r'^login/$',
         auth_views.LoginView.as_view(template_name="registration/v2/login.html"),
         name='login'),

```


### (6) unquote 和quote 这是python范畴的,我也就写这了

```
# 过去
from urllib import unquote
# 现在
from urllib.parse import unquote
```


### (7)自定义标签

```
# 过去
@register.assignment_tag
# 现在
@register.simple_tag

```

---

## 3.model变化

### on_delete加入强制要求

升级完很多人会遇到这个错误

```
TypeError: __init__() missing 1 required positional argument: 'on_delete'
```

过去在model定义的时候`OneToOneField`和`ForeignKey`没有强制要求, 现在强制要求要加上`on_delete`属性.为了快速的解决问题,我全部加上了如下代码

```
on_delete=models.SET_NULL
# 相应的需要把 null=True 加上
```
其实项目本来就应该这样去设计,我们在设计数据库的时候就应该解耦去掉关联性,另外不要轻易的删除数据. 特别是在做微服务的时候,表与表之间最好零关联

## 4.djangorestframework

### 视图里的`filter_backend`

过去是

```
    filter_backends = (filters.DjangoFilterBackend,)

```
现在filter做了变化
```
from django_filters.rest_framework.backends import DjangoFilterBackend
# 然后
    filter_backends = (DjangoFilterBackend,)

```

如果在settings里设置了默认的filter,可以在ViewSet里省去此属性