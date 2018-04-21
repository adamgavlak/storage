defmodule StorageTest do
  use ExUnit.Case

  @some_image "./test/support/some_image.jpg"

  setup do
    File.rm_rf!("test_files")
    :ok
  end

  describe "store file" do
    test "with default options" do
      assert %Storage.File{path: path} = Storage.put(@some_image)
      assert path =~ "some_image.jpg"
      assert :ok == Storage.delete(path)
    end

    test "in simple scope" do
      assert %Storage.File{path: path} = Storage.put(@some_image, scope: 1)
      assert path =~ "1/some_image.jpg"
      assert :ok == Storage.delete(path)
    end

    test "in list scope" do
      %Storage.File{path: path} = Storage.put(@some_image, scope: ["users", 1])
      assert path =~ "users/1/some_image.jpg"
      assert :ok == Storage.delete(path)
    end

    test "with different file name" do
      assert %Storage.File{path: path} = Storage.put(@some_image, filename: "some_other_image.jpg")
      assert path =~ "some_other_image.jpg"
      assert :ok == Storage.delete(path)
    end

    test "with different file name in a scope" do
      %Storage.File{path: path} = Storage.put(@some_image, scope: ["users", 1], filename: "some_other_image.jpg")
      assert path =~ "users/1/some_other_image.jpg"
      assert :ok == Storage.delete(path)
    end
  end

  test "get file url" do
    file = Storage.put(@some_image, scope: ["static"])
    assert Storage.url(file.path) =~ "http://localhost:4000/some_image.jpg"
  end

  test "delete file" do
    file = Storage.put(@some_image)
    assert :ok == Storage.delete(file.path)
  end
end
