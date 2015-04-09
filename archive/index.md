---
layout: default
title: Archive
---

<ul class="post-list">
{% for post in site.posts %}
  {% capture y %}{{post.date | date:"%Y"}}{% endcapture %}
  {% if year != y %}
    {% assign year = y %}
    <li class="listing-separator" id="{{ y }}">[{{ y }}]</li>
  {% endif %}
  <li class="listing-item"><span>{{ post.date | date:"%Y/%m/%d" }}</span> <a href="{{ post.url }}">{{ post.title }}</a></li>    
{% endfor %}
</div>