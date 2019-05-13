require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = generate_grid(10)
  end

  def score
    @attempt = params[:attempt]
    @letters = params[:letters].delete(' ').chars
    @result = final_score(@attempt, @letters)
  end

  private

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    arr = []
    (0...grid_size).each do
      arr << ("A".."Z").to_a.sample
    end
    return arr
  end

  def english_word?(word)
    # create a method to ctrl if the word given is an english one
    # the given word is not an english one
    # a) should compute score of zero for non-english word
    # b) it should build a custom message for an invalid word
    # => not an english word
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    user_serialized = open(url).read
    api_dict_response = JSON.parse(user_serialized)
  
    return api_dict_response["found"]
  end

  def in_the_grid?(word, grid)
    # the given word is not in the grid
    # a) should compute score of zero for word not in the grid
    # b) should build a custom message for a word not in the grid
    # => not in the grid
  
    # the given word has the correct letters but not in sufficient number
    # a) should compute score of zero
    # b) should tell it s not in the grid
    # => not in the grid
  
    # should allow success when answer has repetitive letters
    # :repetitive "season", %w(S S A Z O N E L) Time.now + 1.0
  
    return false if word.gsub(/\W/, "").chars.length > grid.length
  
    result = true
  
    grid_hash = create_hash_from_string(grid.join.downcase)
  
    create_hash_from_string(word).each do |key, value|
      result &= value <= grid_hash[key].to_i
    end
  
    return result
  end

  def create_hash_from_string(word)
    hash_word = {}
    (0...word.gsub(/\W/, "").length).each do |i|
      hash_word[word.gsub(/\W/, "").downcase[i]] = hash_word[word.gsub(/\W/, "").downcase[i]].to_i + 1
    end
    return hash_word
  end

  def final_score(attempt, letters)
    result = {type: 0, attempt: '', letters: ''}
    result = {type: 1, attempt: @attempt.upcase, letters: @letters.join(',')} unless in_the_grid?(@attempt, @letters)
    result = {type: 2, attempt: @attempt.upcase, letters: ''} unless english_word?(@attempt)
    result = {type: 3, attempt: @attempt.upcase, letters: ''} if result[:type].zero?
    return result
  end
end
