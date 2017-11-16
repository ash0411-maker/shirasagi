require 'spec_helper'

describe Article::Node::Base, type: :model, dbscope: :example do
  let(:item) { create :article_node_base }
  it_behaves_like "cms_node#spec_detail"
end

describe Article::Node::Page, type: :model, dbscope: :example do
  let(:item) { create :article_node_page }
  it_behaves_like "cms_node#spec_detail"

  describe "validation" do
    it "basename" do
      item = build(:article_node_page_basename_invalid)
      expect(item.invalid?).to be_truthy
    end
  end

  describe "becomes_with_route" do
    it do
      node = Cms::Node.find(item.id).becomes_with_route
      expect(node.changed?).to be_falsey
    end
  end
end
