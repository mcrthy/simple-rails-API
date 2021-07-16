require 'rails_helper'

RSpec.describe 'API', type: :request do

  # Routes
  let!(:ping_route) { '/api/ping' }
  let!(:posts_route) { '/api/posts' }

  # Valid Query Params
  let!(:tags) do
    { tags: 'history,tech,health' }
  end

  let!(:sort_by_id) do
    { sortBy: 'id' }
  end

  let!(:sort_by_reads) do
    { sortBy: 'reads' }
  end

  let!(:sort_by_likes) do
    { sortBy: 'likes' }
  end

  let!(:sort_by_popularity) do
    { sortBy: 'popularity' }
  end

  let!(:direction_ascending) do
    { direction: 'asc' }
  end

  let!(:direction_descending) do
    { direction: 'dsc' }
  end
  
  # Invalid Query Params
  let!(:invalid_sort) do
    { sortBy: 'author' }
  end

  let!(:invalid_direction) do
    { direction: 'up' }
  end

  # Test suite for GET /api/ping
  describe 'GET /api/ping' do

    before { get ping_route }

    it 'returns an indication of success' do
      expect(json).to eq({'success' => true})
    end

    it 'has a 200 HTTP status' do
      expect(response).to have_http_status(200)
    end
  end

  # Test suite for GET /api/posts
  describe'GET /api/posts' do

    # NOTE: I am using ActionController::ParameterMissing to catch missing or empty tags param. This generates its own
    #       error message, which may differ slightly depending on context, so I am not checking for a specific string.

    context 'when no params are specified' do

      before { get posts_route, params: {} }

      it 'returns a no tags message' do
        expect(json.size).to eq(1)
        expect(json['message']).not_to be_empty
      end

      it 'has a 400 HTTP status' do
        expect(response).to have_http_status(400)
      end 
    end

    context 'when no tags are specified' do
      
      context 'when only sortBy is specified' do

        before { get posts_route, params: sort_by_id }

        it 'returns a no tags message' do
          expect(json.size).to eq(1)
          expect(json['message']).not_to be_empty     
        end

        it 'has a 400 HTTP status' do
          expect(response).to have_http_status(400)
        end
      end

      context 'when only direction is specified' do

        before { get posts_route, params: direction_ascending }

        it 'returns a no tags message' do
          expect(json.size).to eq(1)
          expect(json['message']).not_to be_empty     
        end

        it 'has a 400 HTTP status' do
          expect(response).to have_http_status(400)
        end
      end

      context 'when both sortBy and direction are specified' do

        before {
          get posts_route,
          params: sort_by_id
                  .merge(direction_ascending)
        }

        it 'returns a no tags message' do
          expect(json.size).to eq(1)
          expect(json['message']).not_to be_empty     
        end

        it 'has a 400 HTTP status' do
          expect(response).to have_http_status(400)
        end
      end
    end

    context 'when tags are specified' do

      context 'when no other params are specified' do

        before { get posts_route, params: tags }

        it 'sorts by id in strictly ascending order' do
          expect( (json['posts'].sort_by { |post| post['id']}) ).to eq(json['posts'])
          expect(json['posts'].uniq.size) == json['posts'].size
        end

        it 'has a 200 HTTP status' do
          expect(response).to have_http_status(200)
        end
      end

      context 'when invalid sortBy value is specified' do

        context 'when direction is specified' do

          before { 
            get posts_route,
            params: tags
                    .merge(invalid_sort)
                    .merge(direction_ascending)
          }

          it 'returns an invalid param message' do
            expect(json).to eq( {'message' => 'sortBy parameter is invalid (author).'} )
          end

          it 'has a 400 HTTP status' do
            expect(response).to have_http_status(400)
          end
        end

        context 'when direction is not specified' do

          before {
            get posts_route,
            params: tags
                    .merge(invalid_sort)
          }

          it 'returns an invalid param message' do
            expect(json).to eq( {'message' => 'sortBy parameter is invalid (author).'} )
          end

          it 'has a 400 HTTP status' do
            expect(response).to have_http_status(400)
          end
        end
      end

      context 'when invalid direction is specified' do

        context 'when sortBy is specified' do

          before { 
            get posts_route,
            params: tags
                    .merge(sort_by_id)
                    .merge(invalid_direction)
          }

          it 'returns an invalid param message' do
            expect(json).to eq( {'message' => 'direction parameter is invalid (up).'} )
          end

          it 'has a 400 HTTP status' do
            expect(response).to have_http_status(400)
          end
        end

        context 'when sortBy is not specified' do

          before {
            get posts_route,
            params: tags
                    .merge(invalid_direction)
          }

          it 'returns an invalid param message' do
            expect(json).to eq( {'message' => 'direction parameter is invalid (up).'} )
          end

          it 'has a 400 HTTP status' do
            expect(response).to have_http_status(400)
          end
        end
      end

      context 'when valid sortBy value is specified' do

        context 'when sorting by id' do

          context 'when no direction is specified' do

            before {
              get posts_route,
              params: tags
                      .merge(sort_by_id)
            }

            it 'sorts by id in strictly ascending order' do
              expect( (json['posts'].sort_by { |post| post['id']}) ).to eq(json['posts'])
              expect(json['posts'].uniq.size) == json['posts'].size
            end

            it 'has a 200 HTTP status' do
              expect(response).to have_http_status(200)
            end
          end

          context 'when ascending direcion is specified' do

            before {
              get posts_route,
              params: tags
                      .merge(sort_by_id)
                      .merge(direction_ascending)
            }

            it 'sorts by id in strictly ascending order' do
              expect( (json['posts'].sort_by { |post| post['id']}) ).to eq(json['posts'])
              expect(json['posts'].uniq.size) == json['posts'].size
            end

            it 'has a 200 HTTP status' do
              expect(response).to have_http_status(200)
            end
          end

          context 'when descending direction is specified' do

            before {
              get posts_route,
              params: tags
                      .merge(sort_by_id)
                      .merge(direction_descending)
            }

            it 'sorts by id in strictly descending order' do
              expect( (json['posts'].sort_by { |post| post['id']}.reverse) ).to eq(json['posts'])
              expect(json['posts'].uniq.size) == json['posts'].size
            end

            it 'has a 200 HTTP status' do
              expect(response).to have_http_status(200)
            end
          end
        end

        # NOTE: Ruby sort is not stable by default, so when sorting by fields that can have duplicate values,
        #       I am using sorted_by.with_index to preserve the previous ordering of the list.

        context 'when sorting by reads' do

          context 'when no direction is specified' do

            before {
              get posts_route,
              params: tags
                      .merge(sort_by_reads)
            }

            it 'sorts by reads in ascending order' do
              expect( (json['posts'].sort_by.with_index { |post, i| 
                [ post['reads'],
                  i
                ]})).to eq(json['posts'])
            end

            it 'contains no duplicates' do
              expect(json['posts'].uniq.size) == json['posts'].size
            end

            it 'has a 200 HTTP status' do
              expect(response).to have_http_status(200)
            end
          end

          context 'when ascending direcion is specified' do

            before {
              get posts_route,
              params: tags
                      .merge(sort_by_reads)
                      .merge(direction_ascending)
            }

            it 'sorts by reads in ascending order' do
              expect((json['posts'].sort_by.with_index { |post, i| 
                [ post['reads'],
                  i
                ]})).to eq(json['posts'])
            end

            it 'contains no duplicates' do
              expect(json['posts'].uniq.size) == json['posts'].size
            end

            it 'has a 200 HTTP status' do
              expect(response).to have_http_status(200)
            end
          end

          context 'when descending direction is specified' do

            before {
              get posts_route,
              params: tags
                      .merge(sort_by_reads)
                      .merge(direction_descending)
            }

            it 'sorts by reads in descending order' do
              expect((json['posts'].sort_by.with_index { |post, i| 
                [ post['reads'],
                  -i
                ]}.reverse)).to eq(json['posts'])
            end

            it 'contains no duplicates' do
              expect(json['posts'].uniq.size) == json['posts'].size
            end

            it 'has a 200 HTTP status' do
              expect(response).to have_http_status(200)
            end
          end
        end

        context 'when sorting by likes' do

          context 'when no direction is specified' do

            before {
              get posts_route,
              params: tags
                      .merge(sort_by_likes)
            }

            it 'sorts by likes in ascending order' do
              expect((json['posts'].sort_by.with_index { |post, i| 
                [ post['likes'],
                  i
                ]})).to eq(json['posts'])
            end

            it 'contains no duplicates' do
              expect(json['posts'].uniq.size) == json['posts'].size
            end

            it 'has a 200 HTTP status' do
              expect(response).to have_http_status(200)
            end
          end

          context 'when ascending direcion is specified' do

            before {
              get posts_route,
              params: tags
                      .merge(sort_by_likes)
                      .merge(direction_ascending)
            }

            it 'sorts by likes in ascending order' do
              expect((json['posts'].sort_by.with_index { |post, i| 
                [ post['likes'],
                  i
                ]})).to eq(json['posts'])
            end

            it 'contains no duplicates' do
              expect(json['posts'].uniq.size) == json['posts'].size
            end

            it 'has a 200 HTTP status' do
              expect(response).to have_http_status(200)
            end
          end

          context 'when descending direction is specified' do

            before {
              get posts_route,
              params: tags
                      .merge(sort_by_likes)
                      .merge(direction_descending)
            }

            it 'sorts by likes in descending order' do
              expect((json['posts'].sort_by.with_index { |post, i| 
                [ post['likes'],
                  -i
                ]}.reverse)).to eq(json['posts'])
            end

            it 'contains no duplicates' do
              expect(json['posts'].uniq.size) == json['posts'].size
            end

            it 'has a 200 HTTP status' do
              expect(response).to have_http_status(200)
            end
          end
        end

        context 'when sorting by popularity' do

          context 'when no direction is specified' do

            before {
              get posts_route,
              params: tags
                      .merge(sort_by_popularity)
            }

            it 'sorts by popularity in ascending order' do
              expect((json['posts'].sort_by.with_index { |post, i| 
                [ post['popularity'],
                  i
                ]})).to eq(json['posts'])
            end

            it 'contains no duplicates' do
              expect(json['posts'].uniq.size) == json['posts'].size
            end

            it 'has a 200 HTTP status' do
              expect(response).to have_http_status(200)
            end
          end

          context 'when ascending direcion is specified' do

            before {
              get posts_route,
              params: tags
                      .merge(sort_by_popularity)
                      .merge(direction_ascending)
            }

            it 'sorts by popularity in ascending order' do
              expect((json['posts'].sort_by.with_index { |post, i|
                [ post['popularity'],
                  i
                ]})).to eq(json['posts'])
            end

            it 'contains no duplicates' do
              expect(json['posts'].uniq.size) == json['posts'].size
            end

            it 'has a 200 HTTP status' do
              expect(response).to have_http_status(200)
            end
          end

          context 'when descending direction is specified' do

            before { 
              get posts_route,
              params: tags
                      .merge(sort_by_popularity)
                      .merge(direction_descending)
            }

            it 'sorts by popularity in descending order' do
              expect((json['posts'].sort_by.with_index { |post, i| 
                [ post['popularity'],
                  -i
                ]}.reverse)).to eq(json['posts'])
              
            end

            it 'contains no duplicates' do
              expect(json['posts'].uniq.size) == json['posts'].size
            end

            it 'has a 200 HTTP status' do
              expect(response).to have_http_status(200)
            end
          end
        end
      end
    end
  end
end