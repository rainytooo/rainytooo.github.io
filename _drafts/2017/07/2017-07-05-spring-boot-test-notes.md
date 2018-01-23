---
layout: post
title: spring boot测试笔记一
date: 2017-07-05
category: [language, java]
tags: [spring, spring-boot]
---



### 几点理解

测试环境取决你的测试依赖,如果需要spring boot就使用`@SpringBootTest`,不是的话,你依然可以沿用原来的测试方法,没有影响
但是这两种不完全相等.


```
@RunWith(SpringJUnit4ClassRunner.class)
@WebAppConfiguration
@ContextConfiguration(classes=…)
@ActiveProfiles("test")
```

这样和下面这种都可以达到测试的目的

```
@RunWith(SpringRunner.class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
```



### 上传到nexus3 oss

	vim ~/.m2/settings.xml


```
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                          https://maven.apache.org/xsd/settings-1.0.0.xsd">
  <servers>
    <!--your existing servers are here if any-->
    <server>
      <id>nexus</id>
      <username>admin</username>
      <password>admin123</password>
    </server>
  </servers>
</settings>
```


```
mvn deploy:deploy-file -DgroupId=com.cloopen.rest -DartifactId=ccprestsms -Dversion=v2.6.3r -DgeneratePom=false -Dpackaging=jar -DrepositoryId=nexus -Durl=http://maven.apiusage.com/repository/wantcode-release -Dfile=ccprestsms_v2.6.3r.jar
```


mvn deploy:deploy-file -DgroupId=com.cloopen.rest -DartifactId=ccprestsms -Dversion=v2.6.3r -DgeneratePom=false -Dpackaging=jar -DrepositoryId=nexus -Durl=http://maven.apiusage.com/repository/wantcode-release -Dfile=ccprestsms_v2.6.3r.jar
