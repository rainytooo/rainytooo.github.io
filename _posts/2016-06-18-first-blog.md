---
layout: post
title: First Blog
category: nocat
tags: [wc]
---





```python
class FieldPhotoSerializer(MyModelSerializer):
    """ 照片 """
    # field = FootballFieldSerializer(many=False, read_only=True)
    class Meta:
        model = ClubFieldPhoto
        depth = 0
        fields = ('id', 'club_field', 'photo_small', 'photo_medium', 'photo_large')
```