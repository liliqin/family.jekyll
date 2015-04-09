---
layout: default
title: Categories
---

<div class='cloud'>
{% for cat in site.categories %}
  <a href="#{{ cat[0] }}" title="{{ cat[0] }}" rel="{{ cat[1].size }}">{{ cat[0] }}({{ cat[1].size }})</a>
{% endfor %}
</div>

<ul class="post-list">
{% for cat in site.categories %}
  <li class="listing-separator comment" id="{{ cat[0] }}">[{{ cat[0] }}]</li>
  {% for post in cat[1] %}
    <li class="listing-item"><span>{{ post.date | date:"%Y/%m/%d" }}</span> <a href="{{ post.url }}">{{ post.title }}</a></li>
  {% endfor %}
{% endfor %}
</ul>
