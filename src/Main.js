import TurndownService from "turndown";
import matter from "gray-matter";
import MarkdownIt from "markdown-it";

const md2HtmlService = new MarkdownIt();
const turndownService = new TurndownService();

const htmlToMarkdown = (htmlContent) => turndownService.turndown(htmlContent);

const getEnv = (key) => process.env[key] || "";

const md2Html = (string) => {
  const r = matter(string);
  return {
    frontMatter: r.data,
    content: md2HtmlService.render(r.content),
  };
};

export { htmlToMarkdown, getEnv, md2Html };
