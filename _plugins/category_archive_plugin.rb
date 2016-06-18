# module Jekyll

#   class CategoryPage < Page
#     def initialize(site, base, dir, category)
#       @site = site
#       @base = base
#       @dir = dir
#       @name = 'index.html'

#       self.process(@name)
#       self.read_yaml(File.join(base, '_layouts'), 'category_index.html')
#       self.data['category'] = category

#       category_title_prefix = site.config['category_title_prefix'] || 'Category: '
#       self.data['title'] = "#{category}#{category_title_prefix}"
#     end
#   end

#   class CategoryPageGenerator < Generator
#     safe true

#     def generate(site)
#       if site.layouts.key? 'category_index'
#         dir = site.config['category_dir'] || 'categories'
#         site.categories.each_key do |category|
#           site.pages << CategoryPage.new(site, site.source, File.join(dir, category), category)
#         end
#       end
#     end
#   end

# end

module Jekyll
  module Paginate
    module Category
      
      class Pagination < Generator
        safe true
        priority :lowest

        def generate(site)
          if Paginate::Pager.pagination_enabled?(site)
            site.categories.each do |category, posts|
              total = Paginate::Pager.calculate_pages(posts, site.config['paginate'])
              (1..total).each do |i|
                site.pages << IndexPage.new(site, category, i)
              end
            end
          end
        end
      end

      class IndexPage < Page
        def initialize(site, category, num_page)
          @site = site
          @base = site.source

          category_dir = site.config['category_dir'] || 'categories'
          @dir = File.join(category_dir, category)

          @name = Paginate::Pager.paginate_path(site, num_page)
          @name.concat '/' unless @name.end_with? '/'
          @name += 'index.html'

          self.process(@name)

          # category_layout = site.config['category_layout'] || 'index.html'
          # self.read_yaml(@base, category_layout)
          self.read_yaml(File.join(@base, '_layouts'), 'category_index.html')
          category_title_prefix = site.config['category_title_prefix'] || 'Category: '
          self.data.merge!(
                           'category'  => category,
                           'title'     => "#{category}#{category_title_prefix}",
                           'paginator' => Paginate::Pager.new(site, num_page, site.categories[category])
                          )
        end
      end
      
    end
  end
end