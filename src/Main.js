import matter from "gray-matter";
import dayjs from "dayjs";
import MarkdownIt from "markdown-it";

const md2HtmlService = new MarkdownIt();

const md2Html = (string) => {
  const r = matter(string);
  return {
    frontMatter: r.data,
    content: md2HtmlService.render(r.content),
  };
};

const formatDate = (format) => (dateString) => dayjs(dateString).format(format);

export { md2Html, formatDate };
