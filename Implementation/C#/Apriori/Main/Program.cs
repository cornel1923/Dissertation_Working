using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using AprioriAlgorithm;
using AprioriAlgorithm.Implementation;

namespace Main
{
    public class Program
    {
        static void Main(string[] args)
        {
            var apriori = new Apriori();

            var support = 2;
            var confidence = 0.8;

            var transactions = new[] { "milk~egg~flower", "honey~egg~siroup", "milk~honey~egg~siroup", "honey~siroup", "milk~egg~siroup" };
            var items = new List<string> { "milk", "honey", "egg", "flower", "siroup" };

            //var transactions = new[] { "1~3~4", "2~3~5", "1~2~3~5", "2~5", "1~3~5" };
            //var items = new List<string> { "1", "2", "3", "4", "5" };

            var transactionsTest = ReadTransactionsFile();
            var itemsTest = ReadItemsFile();

            var result = apriori.ProcessTransaction(support, confidence, itemsTest, transactionsTest);

            WriteRules(result.StrongRules);
            WriteFrequent(result.FrequentItems);
            WriteClosest(result.ClosedItemSets);
            WriteMaximal(result.MaximalItemSets);

            Console.WriteLine("Done...");
            Console.Read();
        }

        private static void WriteMaximal(IList<string> maximalItemSets)
        {
            using (var file = new StreamWriter(@"D:\\Disertatie\\Git\\AprioriResults\\maximalItems.txt"))
            {
                foreach (var rule in maximalItemSets)
                {
                    var line = rule;

                    file.Write(line);
                    file.Write(Environment.NewLine);
                }
            }
        }

        private static void WriteClosest(Dictionary<string, Dictionary<string, double>> closest)
        {
            using (var file = new StreamWriter(@"D:\\Disertatie\\Git\\AprioriResults\\closestItems.txt"))
            {
                foreach (var rule in closest)
                {
                    var line = rule.Key + "    ";
                    foreach (var item in rule.Value)
                    {
                        line += "[" + item.Key + "," + item.Value + "]";
                        file.Write(line);

                    }
                    file.Write(Environment.NewLine);
                }
            }
        }

        private static void WriteFrequent(ItemsDictionary frequentItems)
        {
            var orderByDescending = frequentItems.OrderByDescending(x => x.Support);

            using (var file = new StreamWriter(@"D:\\Disertatie\\Git\\AprioriResults\\frequentItems.txt"))
            {
                foreach (var rule in orderByDescending)
                {
                    var line = rule.Name + "    " + rule.Support;

                    file.Write(line);
                    file.Write(Environment.NewLine);
                }
            }
        }

        private static void WriteRules(IList<Rule> rules)
        {
            var orderByDescending = rules.OrderByDescending(x => x.Confidence);

            using (var file = new StreamWriter(@"D:\\Disertatie\\Git\\AprioriResults\\rules.txt"))
            {
                foreach (var rule in orderByDescending)
                {
                    var line = rule.X + "    " + rule.Y + "    " + rule.Confidence;

                    file.Write(line);
                    file.Write(Environment.NewLine);
                }
            }
        }

        private static string[] ReadItemsFile()
        {
            int counter = 0;
            string line;

            var count = File.ReadLines(@"D:\\Disertatie\\Git\\Data_Food\\ingr_info.tsv").Count();

            var lines = new string[count];

            var file = new StreamReader(@"D:\\Disertatie\\Git\\Data_Food\\ingr_info.tsv");

            while ((line = file.ReadLine()) != null)
            {
                var lineData = line.Split('~');

                lines[counter] = lineData[1];

                counter++;
            }

            file.Close();

            return lines;

        }

        public static string[] ReadTransactionsFile()
        {
            int counter = 0;
            string line;

            var count = File.ReadLines(@"D:\\Disertatie\\Git\\Data_Food\\Recipes\\menu_recipes.txt").Count();

            var lines = new string[count];

            StreamReader file = new StreamReader(@"D:\\Disertatie\\Git\\Data_Food\\Recipes\\menu_recipes.txt");

            while ((line = file.ReadLine()) != null)
            {
                var lineData = line.Split('~');
                lineData = lineData.Skip(1).ToArray();

                lines[counter] = string.Join("~", lineData);

                counter++;
            }

            file.Close();

            return lines;
        }
    }
}
