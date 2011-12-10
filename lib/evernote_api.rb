module EvernoteApi
  class Notestore
    def initialize(shard_id)
      noteStoreUrl = NOTESTORE_URL_BASE + shard_id
      noteStoreTransport = Thrift::HTTPClientTransport.new(noteStoreUrl)
      noteStoreProtocol = Thrift::BinaryProtocol.new(noteStoreTransport)
      @noteStore = Evernote::EDAM::NoteStore::NoteStore::Client.new(noteStoreProtocol)
    end

    def listNotebooks(token)
      @noteStore.listNotebooks(token)
    end

    def findNotes(token, noteFilter, offset, limit)
      @noteStore.findNotes(token, noteFilter, offset, limit)
    end
  end
end