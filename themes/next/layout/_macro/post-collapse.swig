{% macro render(post) %}

  <article class="post post-type-{{ post.type | default('normal') }}" itemscope itemtype="http://schema.org/Article">
    <header class="post-header">

      <h1 class="post-title">
        {% if post.link %}{# Link posts #}
          <a class="post-title-link post-title-link-external" target="_blank" href="{{ url_for(post.link) }}" itemprop="url">
            {{ post.title or post.link }}
            <i class="fa fa-external-link-square"></i>
          </a>
        {% else %}
            <a class="post-title-link" href="{{ url_for(post.path) }}" itemprop="url">
              {% if post.type === 'picture' %}
                {{ post.content }}
              {% else %}
                <span itemprop="name">{{ post.title | default(__('post.untitled')) }}</span>
              {% endif %}
            </a>
        {% endif %}
      </h1>

      <div class="post-meta">
        <time class="post-time" itemprop="dateCreated"
              datetime="{{ moment(post.date).format() }}"
              content="{{ date(post.date, config.date_format) }}" >
          {{ date(post.date, 'MM-DD') }}
        </time>
      </div>

    </header>
  </article>
 <!-- wumii  start -->
      {% if theme.favorite_post %}
      <div style="margin:0px auto; padding-left:23px; text-align:center;">
        <script type="text/javascript" id="wumiiRelatedItems"></script>
        <script type="text/javascript">
        var wumiiPermaLink = "{{ page.permalink }}"; //请用代码生成文章永久的链接

        var global_tags = [];
        {% if post.tags and post.tags.length and not is_index %}
          {% for tag in post.tags %}
          global_tags.push('{{tag.name}}');
          {% endfor %}
        {% endif %}
        var categories = [];
         {% if post.categories and post.categories.length and not is_index %}
          {% for cat in post.categories %}
          categories.push('{{cat.name}}');
          {% endfor %}
        {% endif %}
        wumiiTags = global_tags.join(',');
        var wumiiTitle = "{{ post.title }}"; //请用代码生成文章标题
        // wumiiTags =; //请用代码生成文章标签，以英文逗号分隔，如："标签1,标签2"
        var wumiiCategories = categories;
        //var wumiiCategories = [{{ page.categories}}]; //请用代码生成文章分类，分类名放在 JSONArray 中，如: ["分类1", "分类2"]
        var wumiiSitePrefix = "http://liushaojun.github.io/";
        var wumiiParams = "&num=5&mode=3&pf=JAVASCRIPT";
      </script>
      <script type="text/javascript" src="http://widget.wumii.cn/ext/relatedItemsWidget"></script>
      <!-- <a href="http://www.wumii.com/widget/relatedItems" style="border:0;">
          <img src="http://static.wumii.cn/images/pixel.png" alt="无觅关联推荐，快速提升流量" style="border:0;padding:0;margin:0;" />
      </a> -->
      </div>
      {% endif %}
      <!-- wumii end -->
{% endmacro %}
