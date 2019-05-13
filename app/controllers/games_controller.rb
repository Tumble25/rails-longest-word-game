require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = (0...10).map { (65 + rand(26)).chr }
  end

  def score
    @letters = params['letters'].scan(/\w/) #need to make array of it!
    @try = params['try']
    @start_time = Date.parse params['start_time']
    @end_time = Date.parse params['end_time']
    @message = run_game(@try, @letters, @start_time, @end_time)
  end

  private

def run_game(try, letters, start_time, end_time)
  result = { time: end_time - start_time }

  score_and_message = score_and_message(try, letters, result[:time])
  result[:score] = score_and_message.first
  result[:message] = score_and_message.last

  @result = "#{result[:message]}, the score is #{result[:score]}"
end

def compute_score(try, time_taken)
  time_taken > 60.0 ? 0 : try.size * (1.0 - time_taken / 60.0)
end

def included?(try, letters)
  try.chars.all? { |letter| try.count(letter) <= letters.count(letter) }
end

def english_word?(try)
  response = open("https://wagon-dictionary.herokuapp.com/#{try}")
  json = JSON.parse(response.read)
  return json['found']
end

def score_and_message(try, letters, time)
  if included?(try.upcase, letters)
    if english_word?(try)
      score = compute_score(try, time)
      [score, "well done"]
    else
      [0, "not an english word"]
    end
  else
    [0, "not in the grid"]
  end
end
end
