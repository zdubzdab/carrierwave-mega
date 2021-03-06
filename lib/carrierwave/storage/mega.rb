# encoding: utf-8
require 'rmega'

module CarrierWave
  module Storage
    class Mega < Abstract

      # Stubs we must implement to create and save
      # files (here on Dropbox)

      # Store a single file
      def store!(file)
        # new_folder = mega_client.root.create_folder("my_documents")
        location = uploader.store_path
        # storage.root.create_folder(location)
        # location = "/Public/#{location}" if config[:access_type] == "dropbox"
        puts "------#{location}"
        puts file.inspect
        puts "uploader.mounted_as == #{uploader.mounted_as}"
        # mega_client.root.upload(file.to_file)

        if location.to_s.match('videos').to_s.blank?
          file_or_video_folder_name = location.to_s.match('files').to_s
        else
          file_or_video_folder_name = location.to_s.match('videos').to_s
        end

        file_or_video_folder = mega_client.nodes.find do |node|
          node.type == :folder and node.name == file_or_video_folder_name
        end

        if file_or_video_folder.folders.find { |folder| folder.name == "#{uploader.model.id}" }
          file_or_video_folder.folders.find { |folder| folder.name == "#{uploader.model.id}" }.upload(file.to_file)
        else
          file_or_video_folder.create_folder("#{uploader.model.id}").upload(file.to_file)
        end
      end

      # Retrieve a single file
      def retrieve!(file)
        CarrierWave::Storage::Mega::File.new(uploader, config, uploader.store_path(file), mega_client)
      end

      private

      def mega_client
        # @mega_client ||= begin
        #   Rmega.login(config[:mega_email], config[:mega_password])
        # end
        @mega_client = Rmega.login(config[:mega_email], config[:mega_password])
      end

      def config
        @config ||= {}

        # @config[:mega_email] ||= uploader.mega_email
        # @config[:mega_password] ||= uploader.mega_password
        @config[:mega_email] ||= "zdubzdab@gmail.com"
        @config[:mega_password] ||= "mega_nz_password"
        @config
      end

      class File
        include CarrierWave::Utilities::Uri
        attr_reader :path

        def initialize(uploader, config, path, client)
          @uploader, @config, @path, @client = uploader, config, path, client
        end

        def url
          puts "comming to url..."
          # @client.root.files.first
          send_data @client.root.files.first, type: @client.root.files.first.content_type, disposition: "inline"
        end

        def delete
          # path = "/Public/#{path}"
          # begin
          #   @client.delete(path)
          # rescue DropboxError
          # end
        end
      end
    end
  end
end
