# 带分页的标签插件
# 生成静态页面的时候识别标签,每个标签生成一个带分页的集合页面
#

module Jekyll
  module Paginate
    module Tagger
      
      class TagPagination < Generator
        safe true
        priority :lowest

        def generate(site)
          if Paginate::Pager.pagination_enabled?(site)
            site.tags.each do |tag, posts|
              total = Paginate::Pager.calculate_pages(posts, site.config['paginate'])
              (1..total).each do |i|
                site.pages << TagIndexPage.new(site, tag, i)
              end
            end
          end
        end
      end

      class TagIndexPage < Page
        def initialize(site, tag, num_page)
          @site = site
          @base = site.source

          tag_dir = site.config['tag_dir'] || 'tags'
          @dir = File.join(tag_dir, tag)

          @name = Paginate::Pager.paginate_path(site, num_page)
          @name.concat '/' unless @name.end_with? '/'
          @name += 'index.html'

          self.process(@name)

          # tag_layout = site.config['tag_layout'] || 'index.html'
          # self.read_yaml(@base, tag_layout)
          self.read_yaml(File.join(@base, '_layouts'), 'tag_index.html')
          tag_title_prefix = site.config['tag_title_prefix'] || 'Tag: '
          self.data.merge!(
                           'tag'  => tag,
                           'title'     => "#{tag}#{tag_title_prefix}",
                           'paginator' => Paginate::Pager.new(site, num_page, site.tags[tag])
                          )
        end
      end
      
    end
  end
end