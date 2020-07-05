#include <iostream>
#include <HtmlParser/HtmlParser.h>
#include <fstream>

int main(int argc, char** argv) {
	std::ofstream outFile{ "out.txt" };

	if (!outFile.is_open()) {
		std::cout << "Unable to open out file\n";
		exit(-1);
	}
	std::filesystem::path file{ std::string{"Masters Of Sex Torrents - Watch & Download on EZTV.html"} };
	HtmlParser::HtmlParser hp{ file };
	auto dom = hp.parse();
	auto allLinks = dom.getElementsByTagName("a");

	for (const auto &ele : allLinks) {
		if (ele->hasClass("magnet")) {
			outFile << ele->attr("href") << '\n';
			//std::cout << ele->attr("href") << '\n';
		}
	}

	outFile.close();
	/*allLinks.each([](HtmlParser::Element* t, std::size_t i)
	{
			std::cout << t->attr("href") << '\n';
	});*/
    

}
