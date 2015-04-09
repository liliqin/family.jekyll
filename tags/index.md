---
layout: default
title: Tags
---

<div class="cloud">
{% for tag in site.tags %}
  <a href="#{{ tag[0] }}" title="{{ tag[0] }}" rel="{{ tag[1].size }}">{{ tag[0] }}({{ tag[1].size }})</a>
{% endfor %}
</div>

<ul class="post-list">
{% for tag in site.tags %}
  <li class="listing-separator" id="{{ tag[0] }}">[{{ tag[0] }}]</li>
  {% for post in tag[1] %}
  <li class="listing-item"><span>{{ post.date | date:"%Y/%m/%d" }}</span> <a href="{{ post.url }}">{{ post.title }}</a></li>
  {% endfor %}
{% endfor %}
</ul>