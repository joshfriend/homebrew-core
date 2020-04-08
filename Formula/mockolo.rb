class Mockolo < Formula
  desc "Efficient Mock Generator for Swift"
  homepage "https://github.com/uber/mockolo"
  url "https://github.com/uber/mockolo/archive/1.2.0.tar.gz"
  sha256 "e687bee4b1e9979e7e0d94a798d4a430137e07894f5fcbe418a243a3751c1edf"

  bottle do
    cellar :any_skip_relocation
    sha256 "4eb401eeb9dca2a1067e0c30c05d2ca12158b581cfb778e08659c905d42f0479" => :catalina
    sha256 "dc848fc644a2830d58bd3eed39706592098b4c4bc52f2d8c740900bcd94846c3" => :mojave
  end

  depends_on :xcode => ["11.0", :build]

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"
    bin.install ".build/release/mockolo"
  end

  test do
    (testpath/"testfile.swift").write("
    /// @mockable
    public protocol Foo {
        var num: Int { get set }
        func bar(arg: Float) -> String
    }")
    system "#{bin}/mockolo", "-srcs", testpath/"testfile.swift", "-d", testpath/"GeneratedMocks.swift"
    assert_predicate testpath/"GeneratedMocks.swift", :exist?
    assert_equal "
    ///
    /// @Generated by Mockolo
    ///
    public class FooMock: Foo {
      public init() { }
      public init(num: Int = 0) {
          self.num = num
      }

      public var numSetCallCount = 0
      public var num: Int = 0 { didSet { numSetCallCount += 1 } }

      public var barCallCount = 0
      public var barHandler: ((Float) -> (String))?
      public func bar(arg: Float) -> String {
          barCallCount += 1
          if let barHandler = barHandler {
              return barHandler(arg)
          }
          return \"\"
      }
    }".gsub(/\s+/, "").strip, shell_output("cat #{testpath/"GeneratedMocks.swift"}").gsub(/\s+/, "").strip
  end
end
