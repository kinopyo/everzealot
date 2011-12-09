module FileSystem
  module FileZip

    def compress_files_to_zip filename, target_files
      # https://bitbucket.org/winebarrel/zip-ruby/wiki/Home

      File.delete(filename) if File.exists?(filename)

      Zip::Archive.open(filename, Zip::CREATE) do |ar|
          target_files.each do |file|
            ar.add_file(file)
            # File.delete(file) # delete file after added to zip
          end
      end
    end
  end
end