require 'minitest/autorun'
require 'carnivore-files'

describe 'Carnivore::Source::File' do

  before do
    @file_path = '/tmp/carnivore-file-test-1'
    MessageStore.init
    Carnivore::Source.build(
      :type => :carn_file,
      :args => {
        :path => @file_path
      }
    ).add_callback(:store) do |message|
      MessageStore.messages.push(message[:message][:content])
      message.confirm!
    end
    @runner = Thread.new{ Carnivore.start! }
    source_wait
  end

  after do
    if(File.exists?(@file_path))
      File.delete(@file_path)
    end
    @runner.terminate
    Carnivore::Source.clear!
  end

  describe 'File source based communication' do

    before do
      MessageStore.messages.clear
    end

    it 'should automatically start watching file on creation' do
      File.open(@file_path, 'w+') do |file|
        file.puts 'ohai'
      end
      source_wait(6) do
        !MessageStore.messages.empty?
      end
      MessageStore.messages.wont_be_empty
      MessageStore.messages.pop.must_equal 'ohai'
    end

    it 'should automatically track rolled files' do
      File.open(@file_path, 'w+') do |file|
        file.puts 'ohai'
      end
      source_wait(6) do
        !MessageStore.messages.empty?
      end
      MessageStore.messages.wont_be_empty
      MessageStore.messages.pop.must_equal 'ohai'
      File.delete(@file_path)
      File.open(@file_path, 'w+') do |file|
        file.puts 'ack'
      end
      File.open(@file_path, 'w+') do |file|
        file.puts 'ack'
      end
      source_wait(6) do
        !MessageStore.messages.empty?
      end
      MessageStore.messages.wont_be_empty
      MessageStore.messages.pop.must_equal 'ack'
    end

  end
end
