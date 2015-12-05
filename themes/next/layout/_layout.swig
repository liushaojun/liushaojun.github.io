<!doctype html>
<html class="theme-next {% if theme.use_motion %}  use-motion {% endif %}">
<head>
  {% include '_partials/head.swig' %}
  <title>{% block title %}{% endblock %}</title>
</head>

<body itemscope itemtype="http://schema.org/WebPage" lang="{{ config.language }}">

  {% include '_partials/old-browsers.swig' %}
  {% include '_scripts/analytics.swig' %}

  <div class="container one-column {% block page_class %}{% endblock %}">

  <!-- Fork me on Github start -->
  {% if theme.github_icon %}
  <div class="tooltip1 tooltip1-effect" id="fork-on-coding">
    <a href="https://github.com/liushaojun/liushaojun.github.io" title="Fork me on Github">
    Fork me on Github
    </a>
    <span class="tooltip1-content">
    <img src="/images/github.svg">
    </span>
  </div>
  {% endif %}
<!-- ent  -->
    <div class="headband"></div>

    <header id="header" class="header" itemscope itemtype="http://schema.org/WPHeader">
      <div class="header-inner"> {%- include '_partials/header.swig' %} </div>
    </header>

    <main id="main" class="main">
      <div class="main-inner">
        <div id="content" class="content">
          {% block content %}{% endblock %}
        </div>

        {% include '_partials/duoshuo-hot-articles.swig' %}
        {% include '_partials/comments.swig' %}
      </div>

      {% if theme.sidebar !== 'remove' %}
        {% block sidebar %}{% endblock %}
      {% endif %}
    </main>

    <footer id="footer" class="footer">
      <div class="footer-inner">
        {% include '_partials/footer.swig' %}
      </div>
    </footer>

    <div class="back-to-top"></div>
  </div>

  <script type="text/javascript" src="{{ url_for(theme.vendors) }}/jquery/index.js?v=2.1.3"></script>

  {# This block is used to set options before any other scripts run #}
  {% block script_extra_before %}{% endblock %}

  {% block comment_system %}
    {% include '_scripts/comments/duoshuo.swig' %}
    {% include '_scripts/comments/disqus.swig' %}
  {% endblock %}

  {% include '_scripts/fancy-box.swig' %}
  {% include '_scripts/helpers.swig' %}
  {% include '_scripts/motion.swig' %}

  <script type="text/javascript" src="{{ url_for(theme.vendors) }}/fastclick/lib/fastclick.min.js?v=1.0.6"></script>
  <script type="text/javascript" src="{{ url_for(theme.vendors) }}/jquery_lazyload/jquery.lazyload.js?v=1.9.7"></script>

  {% block script_extra %}{% endblock %}

  <script type="text/javascript" src="{{ url_for(theme.js) }}/bootstrap.js"></script>

  {% include '_scripts/tinysou.swig' %}
  {% include '_scripts/mathjax.swig' %}
  {% block comment_system %}{% endblock %}
  {% include '_scripts/baidushare.swig' %}
{# <a href="https://github.com/liushaojun">
<img style="position: absolute; top: 0; left: 0; border: 0;" src="https://camo.githubusercontent.com/82b228a3648bf44fc1163ef44c62fcc60081495e/68747470733a2f2f73332e616d617a6f6e6177732e636f6d2f6769746875622f726962626f6e732f666f726b6d655f6c6566745f7265645f6161303030302e706e67" alt="Fork me on GitHub" data-canonical-src="https://s3.amazonaws.com/github/ribbons/forkme_left_red_aa0000.png"></a> #}
</body>
</html>
