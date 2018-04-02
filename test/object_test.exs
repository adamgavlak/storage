defmodule StorageObjectTest do
  use ExUnit.Case

  defmodule TestObject do
    use Storage.Object,
      dir: "static/objects"
  end

  @some_file "./test/support/some_image.jpg"

  test "store file as an object" do
    assert %Storage.File{} = TestObject.store(@some_file)
    assert :ok == TestObject.delete("some_image.jpg")
  end

  test "store %Plug.Upload{} as an object" do
    upload = %Plug.Upload{content_type: "image/jpeg", path: @some_file, filename: "some_other_name.jpg"}
    assert %Storage.File{} = TestObject.store(upload)
    assert :ok == TestObject.delete("some_other_name.jpg")
  end

  test "get stored object URL using filename and scope" do
    TestObject.store(@some_file, 1)
    assert TestObject.url("some_image.jpg", 1) =~ "localhost:4000/objects/1/some_image.jpg"
    assert :ok == TestObject.delete("some_image.jpg", 1)
  end

  test "delete object using filename and scope" do
    TestObject.store(@some_file, ["dir", 1])
    assert :ok == TestObject.delete("some_image.jpg", ["dir", 1])
  end
end
