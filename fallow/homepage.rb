module Fallow
  class Homepage
    def recent_articles( num = 5 )
      Fallow::Cache.get_recent_articles( num )
    end
    def recent_bookmarks( num = 5 )
      Fallow::Cache.get_recent_bookmarks( num )
    end

    def render ( caching_enabled = true)
      recency = 0
      
      articles = recent_articles( 10 ).each {|article|
        recency = article['published'] if article['published'] > recency
        article['url'] = article['path']
        article['published'] = Time.at(article['published']).strftime('%B %d, %Y')
        article['modified'] = Time.at(article['modified']).strftime('%B %d, %Y')
      }
      bookmarks = recent_bookmarks( 5 ).each{|bookmark|
        recency = bookmark['published'] if bookmark['published'] > recency
      }

      templater = Fallow::Template.new( 'homepage' )
      @page_html = templater.render({
        :lists          =>  {
          'recent_writing'  =>  articles,
          'recent_link'     =>  bookmarks
        }
      })
      
      persist if caching_enabled

      Fallow::Dispatch.cache_headers( @page_html, recency )
    end
    
private

    def persist
      html_filename = HTML_ROOT + '/index.html'
      File.open( html_filename, 'w' ) { |f| f.write( @page_html ) }
    end
    
  end
end