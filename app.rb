#!/usr/bin/env ruby

require 'airrecord'
require 'kramdown'
require 'sinatra'

Row = Struct.new(:title, :author, :text, :image, :submitted, :created) do
  def inspect
    to_h.to_s
  end

  def text_to_html
    Kramdown::Document.new(text.gsub("\n", "<br>")).to_html
  end
end

class App < Sinatra::Base
  APP_KEY = ENV["APP_KEY"]
  API_KEY = ENV["API_KEY"]
  TABLE = ENV["TABLE"]
  TITLE = ENV["TITLE"]
  
  class << self
    def refresh_settings
      settings = refresh_sheet
      set(:rows) {settings[:rows]}
      set(:title) {settings[:title]}
    end

    def refresh_sheet
      poem = Airrecord.table(API_KEY, APP_KEY, TABLE)
      title = TITLE
      rows = []
      poem.all.each do |row|
        rows << Row.new(
          row['Title'],
          row['Author'],
          row['Text'],
          row['Image'],
          row['Submitted By'],
          row.created_at
        )
      end
      {
        rows: rows,
        title: title
      }
    end
  end

  configure do
    refresh_settings
  end

  before do
    @title = settings.title
  end

  get "/" do
    @rows = settings.rows
    erb :index
  end

  get "/refresh" do
    self.class.refresh_settings
    redirect "/"
  end

  get "/search" do
    @search = params['q']
    case @search
    when /^from: */i
      # submitter search
      pattern = Regexp.new(@search.sub(/from: */i, ''), Regexp::IGNORECASE)
      @rows = settings.rows.filter do |row|
        pattern.match?(row.submitted)
      end
    when /^by: */i
      # author search
      pattern = Regexp.new(@search.sub(/by: */i, ''), Regexp::IGNORECASE)
      @rows = settings.rows.filter do |row|
        pattern.match?(row.author)
      end
    else
      pattern = Regexp.new(@search, Regexp::IGNORECASE)
      @rows = settings.rows.filter do |row|
        pattern.match?(row.title) ||
        pattern.match?(row.text) ||
        pattern.match?(row.author)
      end
    end
    erb :index
  end
end
