using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;

namespace Data
{
    public class Program
    {
        static void Main(string[] args)
        {
            CreateCategoriesRecepies();
            //ReadCategories();
            // ExtractData();
        }

        private static void CreateCategoriesRecepies()
        {
            const Int32 BufferSize = 128;

            Dictionary<string, string> extractedData = new Dictionary<string, string>();
            List<string> items = new List<string>();
            using (var fileStream = File.OpenRead(@"D:\Disertatie\Full_Data\Recieps\countries\ingr_info.txt"))
            using (var streamReader = new StreamReader(fileStream, Encoding.UTF8, true, BufferSize))
            {
                string line;
                while ((line = streamReader.ReadLine()) != null)
                {
                    var data = line.Split(',');

                    extractedData[data[0]] = data[1];
                }
            }

            using (var fileStream = File.OpenRead(@"D:\Disertatie\Full_Data\Recieps\countries\all.txt"))
            using (var streamReader = new StreamReader(fileStream, Encoding.UTF8, true, BufferSize))
            {
                string line;
                while ((line = streamReader.ReadLine()) != null)
                {
                    var data = line.Split(',');
                    var newData = new List<string>();

                    foreach (var item in data)
                    {
                        newData.Add(extractedData[item]);
                    }

                    items.Add(string.Join(",", newData));
                }
            }

            WriteCategories(items);
        }

        private static void ExtractData()
        {
            string[] paths = new[]
            {
                "D:/Disertatie/Full_Data/Recieps/allr_recipes.txt",
                "D:/Disertatie/Full_Data/Recieps/epic_recipes.txt",
                "D:/Disertatie/Full_Data/Recieps/menu_recipes.txt"
            };

            foreach (var path in paths)
            {
                var data = ReadFile(path);

                foreach (var item in data)
                {
                    WriteFile(item.Key, item.Value);
                }
            }
        }

        private static void ReadCategories()
        {
            const Int32 BufferSize = 128;

            Dictionary<string, string> extractedData = new Dictionary<string, string>();

            using (var fileStream = File.OpenRead(@"d:\Disertatie\Git\Data_Food\ingr_info_test.tsv"))
            using (var streamReader = new StreamReader(fileStream, Encoding.UTF8, true, BufferSize))
            {
                string line;
                while ((line = streamReader.ReadLine()) != null)
                {
                    var data = line.Split(new string[] { "\t" }, StringSplitOptions.None);

                    extractedData[data[1]] = data[2];

                }
            }


            string path = @"D:/Disertatie/Full_Data/Recieps/countries/ingr_info.txt";

            using (StreamWriter sw = File.CreateText(path))
            {
                foreach (var line in extractedData)
                {
                    sw.WriteLine(line.Key + "," + line.Value);
                }
            }
        }

        private static Dictionary<string, List<string>> ReadFile(string fileName)
        {
            const Int32 BufferSize = 128;

            Dictionary<string, List<string>> dataCountries = new Dictionary<string, List<string>>();

            using (var fileStream = File.OpenRead(fileName))
            using (var streamReader = new StreamReader(fileStream, Encoding.UTF8, true, BufferSize))
            {
                string line;
                while ((line = streamReader.ReadLine()) != null)
                {
                    var data = line.Split(new string[] { "\t" }, StringSplitOptions.None);

                    var country = data[0].ToLower();

                    string[] copy = new string[data.Length - 1];
                    Array.Copy(data, 1, copy, 0, data.Length - 1);

                    if (dataCountries.ContainsKey(country))
                    {
                        dataCountries[country].Add(string.Join(",", copy));
                    }
                    else

                    {
                        dataCountries[country] = new List<string>
                        {
                            string.Join(",", copy)
                        };
                    }
                    WriteALlInOne(string.Join(",", copy));
                }
            }
            return dataCountries;
        }

        private static void WriteFile(string name, List<string> data)
        {
            string path = @"D:/Disertatie/Full_Data/Recieps/countries/" + name + ".txt";

            if (!File.Exists(path))
            {
                using (StreamWriter sw = File.CreateText(path))
                {
                    foreach (var line in data)
                    {
                        sw.WriteLine(line);
                    }
                }
            }
            else
            {
                StreamWriter sw = File.AppendText(path);

                foreach (var line in data)
                {
                    sw.WriteLine(line);
                }
                sw.Close();
            }
        }




        private static void WriteALlInOne(string data)
        {
            string path = @"D:/Disertatie/Full_Data/Recieps/countries/all.txt";

            if (!File.Exists(path))
            {
                using (StreamWriter sw = File.CreateText(path))
                {
                    sw.WriteLine(data);
                }
            }
            else
            {
                StreamWriter sw = File.AppendText(path);
                sw.WriteLine(data);
                sw.Close();
            }
        }


        private static void WriteCategories(List<string> data)
        {
            string path = @"D:/Disertatie/Full_Data/Recieps/countries/all_categories.txt";

            using (StreamWriter sw = File.CreateText(path))
            {
                foreach (var item in data)
                {
                    sw.WriteLine(item);
                }
            }
        }


    }
}
