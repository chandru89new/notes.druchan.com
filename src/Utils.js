import matter from "gray-matter";
import dayjs from "dayjs";
import MarkdownIt from "markdown-it";
import TurndownService from "turndown";

const md2FormattedDataService = new MarkdownIt();

const md2FormattedData = (string) => {
  const r = matter(string);
  return {
    frontMatter: r.data,
    content: md2FormattedDataService.render(r.content),
  };
};

const formatDate = (format) => (dateString) => dayjs(dateString).format(format);

const turndownService = new TurndownService();

const htmlToMarkdown = (htmlContent) => turndownService.turndown(htmlContent);

const getEnv = (key) => process.env[key] || "";

export { md2FormattedData, formatDate, htmlToMarkdown, getEnv };
