module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    # Mapping can be updated via the REST endpoint using PUT /my-index/_mapping and read via GET /my-index/_mapping
    mapping do
      indexes :artist, type: :text
      indexes :title, type: :text
      indexes :lyrics, type: :text
      indexes :genre, type: :keyword
    end
    # % rails console
    # Loading development environment (Rails 7.2.2.1)
    # songs-api(dev)> Song.__elasticsearch__.create_index!
  end



  def self.search(query, genre = nil)
    params = {
      query: {
        #  bool, which is just a way to combine multiple queries into one
        bool: {
          # contribute to score,
          # must logical AND
          # should logical OR
          # must_not is logical NOT
          must: [
            {
              multi_match: {
                query: query,
                fields: [ :title, :artist, :lyrics ]
              }
            },
            # filter out
            filter: [
              {
                term: { genre: genre }
              }
            ]
          ]
        }
      }
    }

    def self.search_boost_artist(query)
      params = {
        query: {
          bool: {
            # three queries separately (one per field): they are essentially combined using logical OR
            should: [
              { match: { title: query } },
              # BOOST IS DEPRECATED
              # Fuzzysearch :)
              { match: { artist: { query: query, boost: 5, fuzziness: "AUTO"  } } },
              { match: { lyrics: query } }
            ]
          }
        },
        highlight: { fields: { title: {}, artist: {}, lyrics: {} } }
      }

      self.__elasticsearch__.search(params)
    end

    self.__elasticsearch__.search(params)
  end
end
