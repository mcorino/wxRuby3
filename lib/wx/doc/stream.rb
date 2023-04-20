
class Wx::InputStream

  # @overload read(size)
  #   Reads max size bytes from stream.
  #   @param [Integer] size max number of bytes to read
  #   @return [String,nil] string with bytes read (nil if none read)
  # @overload read(output)
  #   Reads bytes from stream and writes these to output stream until eof or error.
  #   @param [IO,Wx::OutputStream] output output stream to write to
  #   @return [self]
  def read(*args); end

  #   Reads size bytes from stream (until eof or error).
  #   @param [Integer] size number of bytes to read
  #   @return [String,nil] string with bytes read (nil if none read)
  def read_all(size); end

end

class Wx::OutputStream

  # @overload write(buffer)
  #   Writes some or all bytes from buffer to stream.
  #   @param [String] buffer string with bytes to write
  #   @return [Integer] number of bytes written
  # @overload write(input)
  #   Write bytes read from input stream (until eof or error)
  #   @param [IO,Wx::InputStream] input input stream to read from
  #   @return [self]
  def write(*args); end

  # Writes bytes from buffer to stream.
  # @param [String] buffer string with bytes to write
  # @return [Integer] number of bytes written
  def write_all(buffer); end

end
