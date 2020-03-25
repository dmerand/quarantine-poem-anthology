#!/usr/bin/env ruby

require 'airrecord'
require 'kramdown'
require 'sinatra'

Row = Struct.new(:id, :title, :author, :text, :image, :submitted, :created) do
  def inspect
    to_h.to_s
  end

  def image_to_html
    if image.nil?
      ""
    else
      <<~IMG
        <img src="#{image[0]['url']}" alt="#{title} by #{author}">
      IMG
    end
  end

  def text_to_html
    if text.nil?
      ""
    else
      Kramdown::Document.new(text.gsub("\n", "<br>")).to_html
    end
  end

  def to_html
    <<~HTML
      #{text_to_html if text}#{"<br><br>" if text}
      #{image_to_html if image}
    HTML
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
          row.id,
          row['Title'],
          row['Author'],
          row['Text'],
          row['Image'],
          row['Submitted By'],
          row.created_at
        )
      end
      {
        rows: rows.sort_by{|row| row.created}.reverse,
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

  get "/poems/:id" do
    @rows = settings.rows.filter {|row| row.id.match? params[:id]}
    erb :index
  end

  get "/rss.xml" do
    @rows = settings.rows
    builder do |xml|
      xml.instruct! :xml, :version => '1.0'
      xml.rss :version => "2.0" do
        xml.channel do
          xml.title @title
          xml.description ""
          xml.link ENV["SITE_URL"]

          @rows.each do |row|
            xml.item do
              xml.title row.title
              xml.description row.to_html
              xml.link "#{ENV['SITE_URL']}/poems/#{row['id']}"
              xml.pubDate Time.parse(row.created.to_s).rfc822()
              xml.guid "#{ENV['SITE_URL']}/poems/#{row['id']}"
            end
          end
        end
      end
    end
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
