---
layout: post
title: Java8和Joda的日期
date: 2016-07-20
category: [language, java, java advanced]
tags: [java, joda]
---


# Java8和Joda的日期时区以及持久化和序列化反序列化

### jdbc转jsr310和joda日期

```java
        // 
        DemoTable dt = new DemoTable();

        // ------------- jdbc转 jsr310 的LocalDate
        // 使用jsr310
        Date createDate = rs.getDate("create_date");
        LocalDate localCreateDate = createDate.toLocalDate();
        dt.setCreateDate(localCreateDate);
        // ------------- jdbc转 joda 的LocalDate
        // 使用 joda
        Date createDate = rs.getDate("create_date");
        dt.setCreateDate(new LocalDate(createDate));

        // -------------- jdbc转 jsr310 的LocalDateTime
        Timestamp tsUpdateDate = rs.getTimestamp("update_date");
        LocalDateTime localUpdateDate = tsUpdateDate.toLocalDateTime();
        dt.setUpdateDate(localUpdateDate);

        // -------------- jdbc转 joda 的 LocalDateTime
        DateTimeZone zone = DateTimeZone.forID("Asia/Shanghai");
        LocalDateTime localUpdateDate = new LocalDateTime(rs.getTimestamp("create_date"), zone);
        dt.setUpdateDate(localUpdateDate);

        // --------------- jdbc转 jsr310 的ZonedDateTime
        Timestamp zdtTimeStamp = rs.getTimestamp("zdt_date");
        ZonedDateTime utcDateTime = ZonedDateTime.ofInstant(zdtTimeStamp.toInstant(), ZoneId.of("UTC"));
        dt.setZdtDateTime(utcDateTime);
        return dt;
```

还是Joda的转化做的灵活些,构造方法参数是Object类型的.


### Jpa转jsr310和joda的日期

主要是通过Type来转换

##### 转jsr310

```java
@Type(type = "org.jadira.usertype.dateandtime.threeten.PersistentLocalDate")
@Type(type = "org.jadira.usertype.dateandtime.threeten.PersistentLocalDateTime")
@Type(type = "org.jadira.usertype.dateandtime.threeten.PersistentZonedDateTime")
```

目前这个转换有个bug,jdbc是自己控制没问题,jpa和spring data jpa 转换过来的LocalDate和LocalDatetime是UTC时间,
虽然可以通过下面的方式设置时区参数,但是只能设置为UTC也就是Z,其它的会报错,
参考[How to setup jadira PersistentLocalDateTime with java.time.LocalDateTime?](http://stackoverflow.com/questions/31826867/how-to-setup-jadira-persistentlocaldatetime-with-java-time-localdatetime)


```java
    @Type(type = "org.jadira.usertype.dateandtime.threeten.PersistentLocalDateTime",
          parameters = {@Parameter(name = "databaseZone", value = "Z"),
                        @Parameter(name = "javaZone", value = "jvm")})
```


##### 转Joda

```java
@Type(type = "org.jadira.usertype.dateandtime.joda.PersistentLocalDate")
@Type(type = "org.jadira.usertype.dateandtime.joda.PersistentLocalDateTime")
@Type(type = "org.jadira.usertype.dateandtime.joda.PersistentDateTime")
```



### 序列化

主要使用jackson,的`@JsonFormat`和`@JsonSerialize`

```java
@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
或者
@JsonSerialize(using = CustomDateSerializer.class)
```

一个CustomDateSerializer

```java
class CustomDateSerializer extends JsonSerializer<LocalDateTime> {
    private SimpleDateFormat formatter =
            new SimpleDateFormat("dd-MM-yyyy hh");

    @Override
    public void serialize (Date value, JsonGenerator gen, SerializerProvider arg2)
            throws IOException, JsonProcessingException {
        gen.writeString(formatter.format(value));
    }

    @Override
    public void serialize(LocalDateTime value, JsonGenerator gen, SerializerProvider serializers) throws IOException, JsonProcessingException {

        gen.writeString(String.valueOf(Timestamp.valueOf(value).getTime()));
    }
```


### 参看

* [Joda](http://www.joda.org/joda-time/)
* [Convert LocalDate to LocalDateTime or java.sql.Timestamp](http://stackoverflow.com/questions/8992282/convert-localdate-to-localdatetime-or-java-sql-timestamp)
* [Java 8新的时间日期库的20个使用示例](http://www.importnew.com/16814.html)
* [Jackson序列化时间](http://www.baeldung.com/jackson-serialize-dates)
* [hibernate时间转换](http://stackoverflow.com/questions/27750026/java-8-localdatetime-and-hibernate-4)
* [How to get a java.time object from a java.sql.Timestamp without a JDBC 4.2 driver?](http://stackoverflow.com/questions/22470150/how-to-get-a-java-time-object-from-a-java-sql-timestamp-without-a-jdbc-4-2-drive)




