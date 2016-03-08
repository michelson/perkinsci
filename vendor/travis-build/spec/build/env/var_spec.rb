require 'spec_helper'

describe Travis::Build::Env::Var do
  def parse(line)
    described_class.parse(line)
  end

  def var(key, value, options = {})
    described_class.new(key, value, options)
  end

  describe 'parse' do
    it 'parses SECURE FOO=foo BAR=bar' do
      expect(parse('SECURE FOO=foo BAR=bar')).to eq([["FOO", "foo", secure: true], ["BAR", "bar", secure: true]])
    end

    it 'parses FOO=foo BAR=bar' do
      expect(parse('FOO=foo BAR=bar')).to eq([['FOO', 'foo'], ['BAR', 'bar']])
    end

    it 'parses FOO="" BAR=bar' do
      expect(parse('FOO="" BAR=bar')).to eq([['FOO', '""'], ['BAR', 'bar']])
    end

    it 'parses FOO="foo" BAR=bar' do
      expect(parse('FOO="foo" BAR=bar')).to eq([['FOO', '"foo"'], ['BAR', 'bar']])
    end

    it 'parses FOO="foo" BAR="bar"' do
      expect(parse('FOO="foo" BAR="bar"')).to eq([['FOO', '"foo"'], ['BAR', '"bar"']])
    end

    it "parses FOO='' BAR=bar" do
      expect(parse("FOO='' BAR=bar")).to eq([['FOO', "''"], ['BAR', 'bar']])
    end

    it "parses FOO='foo' BAR=bar" do
      expect(parse("FOO='foo' BAR=bar")).to eq([['FOO', "'foo'"], ['BAR', 'bar']])
    end

    it "parses FOO='foo' BAR='bar'" do
      expect(parse("FOO='foo' BAR='bar'")).to eq([['FOO', "'foo'"], ['BAR', "'bar'"]])
    end

    it "parses FOO='foo' BAR=\"bar\"" do
      expect(parse("FOO='foo' BAR=\"bar\"")).to eq([['FOO', "'foo'"], ['BAR', '"bar"']])
    end

    it 'parses FOO="foo foo" BAR=bar' do
      expect(parse('FOO="foo foo" BAR=bar')).to eq([['FOO', '"foo foo"'], ['BAR', 'bar']])
    end

    it 'parses FOO="foo foo" BAR="bar bar"' do
      expect(parse('FOO="foo foo" BAR="bar bar"')).to eq([['FOO', '"foo foo"'], ['BAR', '"bar bar"']])
    end
  end

  describe 'secure?' do
    it 'returns true if the var name starts with SECURE' do
      args = parse('SECURE FOO=foo').first
      expect(var(*args)).to be_secure
    end

    it 'returns true if var is created with secure argument' do
      expect(var('FOO', 'foo', secure: true)).to be_secure
    end
  end

  describe 'echo?' do
    it 'returns true for other vars' do
      expect(var(:FOO, 'foo', type: :settings)).to be_echo
    end

    it 'returns false for internal vars' do
      expect(var(:TRAVIS_FOO, 'foo', type: :builtin)).not_to be_echo
    end
  end
end
