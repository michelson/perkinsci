module Perkins
  class Commit

    attr_reader :sha
    attr_accessor :branch

    def initialize(sha,  repo)
      return if sha.nil?
      @commit = repo.git.gcommit(sha)
      @sha = sha
    end

    def author
      @commit.author.name unless @commit.blank?
    end

    def email
      @commit.author.email unless @commit.blank?
    end

    def created_at
      @commit.author.date unless @commit.blank?
    end

    def message
      @commit.message unless @commit.blank?
    end

    def as_json(opts={})
      data = {}
      fields = [:author, :email, :created_at, :message, :sha]
      fields.each{|f| data[f] = send(f)}
      data
    end

  end
end