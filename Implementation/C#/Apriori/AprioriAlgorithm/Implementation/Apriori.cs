using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using AprioriAlgorithm.Entities;

namespace AprioriAlgorithm.Implementation
{
    public class Apriori
    {
        #region Member Variables

        private char separator = '~';

        #endregion

        #region IApriori

        public Output ProcessTransaction(double minSupport, double minConfidence, IEnumerable<string> items, string[] transactions)
        {
            Console.WriteLine("Computing frequentItems");

            var frequentItems = GetFirstListOfFrequentItems(minSupport, items, transactions);

            var allFrequentItems = new ItemsDictionary();

            allFrequentItems.ConcatItems(frequentItems);

            IDictionary<string, double> candidates;

            double transactionsCount = transactions.Length;

            do
            {
                candidates = GenerateCandidates(frequentItems, transactions);
                Console.WriteLine(candidates.Count + " candidates.");
                frequentItems = GetFrequentItems(candidates, minSupport, transactionsCount);
                allFrequentItems.ConcatItems(frequentItems);
            }
            while (candidates.Count != 0);
            
            Console.WriteLine("Computing output:...");
            return ComputeOutput(minConfidence, allFrequentItems);
        }

        private Output ComputeOutput(double minConfidence, ItemsDictionary allFrequentItems)
        {
            var rules = GenerateRules(allFrequentItems);
            var strongRules = GetStrongRules(minConfidence, rules, allFrequentItems);
            var closedItemSets = GetClosedItemSets(allFrequentItems);
            var maximalItemSets = GetMaximalItemSets(closedItemSets);

            return new Output
            {
                StrongRules = strongRules,
                MaximalItemSets = maximalItemSets,
                ClosedItemSets = closedItemSets,
                FrequentItems = allFrequentItems
            };
        }

        #endregion

        #region Private Methods

        private List<Item> GetFirstListOfFrequentItems(double minSupport, IEnumerable<string> items, IEnumerable<string> transactions)
        {
            var frequentItems = new List<Item>();

            foreach (var item in items)
            {
                var support = GetSupport(item, transactions);

                if (support >= minSupport)
                {
                    frequentItems.Add(new Item { Name = item, Support = support });
                }
            }

            frequentItems.Sort();

            return frequentItems;
        }

        private double GetSupport(string generatedCandidate, IEnumerable<string> transactionsList)
        {
            double support = 0;

            foreach (var transaction in transactionsList)
            {
                if (IsSubset(generatedCandidate, transaction))
                {
                    support++;
                }
            }

            return support;
        }

        private bool IsSubset(string child, string parent)
        {
            var childData = child.Split('~');

            foreach (var item in childData)
            {
                if (!parent.Contains(item))
                {
                    return false;
                }
            }

            return true;
        }

        private Dictionary<string, double> GenerateCandidates(IList<Item> frequentItems, IEnumerable<string> transactions)
        {
            Dictionary<string, double> candidates = new Dictionary<string, double>();

            for (int i = 0; i < frequentItems.Count - 1; i++)
            {
                string firstItem = CustomSort(frequentItems[i].Name);

                for (int j = i + 1; j < frequentItems.Count; j++)
                {
                    string secondItem = CustomSort(frequentItems[j].Name);

                    string generatedCandidate = GenerateCandidate(firstItem, secondItem);

                    if (generatedCandidate != string.Empty)
                    {
                        double support = GetSupport(generatedCandidate, transactions);
                        candidates.Add(generatedCandidate, support);
                    }
                }
            }

            return candidates;
        }

        private string GenerateCandidate(string firstItem, string secondItem)
        {
            int length = firstItem.Split(separator).Length;

            if (length == 1)
            {
                return firstItem + separator + secondItem;
            }
            else
            {
                var firstData = firstItem.Split(separator);
                var secondData = secondItem.Split(separator);

                string firstSubString = "";
                string secondSubString = "";

                for (int i = 0; i < length - 1; i++)
                {
                    firstSubString += firstData[i];
                    secondSubString += secondData[i];
                }

                if (firstSubString == secondSubString)
                {
                    return firstItem + separator + secondData[length - 1];
                }

                return string.Empty;
            }
        }

        private List<Item> GetFrequentItems(IDictionary<string, double> candidates, double minSupport, double transactionsCount)
        {
            var frequentItems = new List<Item>();

            foreach (var item in candidates)
            {
                if (item.Value >= minSupport)
                {
                    frequentItems.Add(new Item { Name = item.Key, Support = item.Value });
                }
            }

            return frequentItems;
        }

        private Dictionary<string, Dictionary<string, double>> GetClosedItemSets(ItemsDictionary allFrequentItems)
        {
            var closedItemSets = new Dictionary<string, Dictionary<string, double>>();
            int i = 0;

            foreach (var item in allFrequentItems)
            {
                Dictionary<string, double> parents = GetItemParents(item.Name, ++i, allFrequentItems);

                if (CheckIsClosed(item.Name, parents, allFrequentItems))
                {
                    closedItemSets.Add(item.Name, parents);
                }
            }

            return closedItemSets;
        }

        private Dictionary<string, double> GetItemParents(string child, int index, ItemsDictionary allFrequentItems)
        {
            var parents = new Dictionary<string, double>();

            for (int j = index; j < allFrequentItems.Count; j++)
            {
                string parent = allFrequentItems[j].Name;

                if (parent.Split(separator).Length == child.Split(separator).Length + 1)
                {
                    if (IsSubset(child, parent))
                    {
                        parents.Add(parent, allFrequentItems[parent].Support);
                    }
                }
            }

            return parents;
        }

        private bool CheckIsClosed(string child, Dictionary<string, double> parents, ItemsDictionary allFrequentItems)
        {
            foreach (string parent in parents.Keys)
            {
                if (allFrequentItems[child].Support == allFrequentItems[parent].Support)
                {
                    return false;
                }
            }

            return true;
        }

        private IList<string> GetMaximalItemSets(Dictionary<string, Dictionary<string, double>> closedItemSets)
        {
            var maximalItemSets = new List<string>();

            foreach (var item in closedItemSets)
            {
                Dictionary<string, double> parents = item.Value;

                if (parents.Count == 0)
                {
                    maximalItemSets.Add(item.Key);
                }
            }

            return maximalItemSets;
        }

        private HashSet<Rule> GenerateRules(ItemsDictionary allFrequentItems)
        {
            var rulesList = new HashSet<Rule>();

            foreach (var item in allFrequentItems)
            {
                var data = item.Name.Split(separator);

                if (data.Length > 1)
                {
                    IEnumerable<string> subsetsList = GenerateSubsets(data);

                    foreach (var subset in subsetsList)
                    {
                        var subsetData = subset.Split(separator);

                        string[] remaining = GetRemaining(subsetData, data);

                        Rule rule = new Rule(subset, ConvertStringArrayToString(remaining), 0);

                        if (!rulesList.Contains(rule))
                        {
                            rulesList.Add(rule);
                        }
                    }
                }
            }

            return rulesList;
        }

        static string ConvertStringArrayToString(string[] array)
        {
            //
            // Concatenate all the elements into a StringBuilder.
            //
            StringBuilder builder = new StringBuilder();

            int counter = 0;

            foreach (string value in array)
            {
                builder.Append(value);

                counter++;

                if (counter > 0 && counter < array.Length)
                {
                    builder.Append("~");
                }
            }

            return builder.ToString();
        }


        private IEnumerable<string> GenerateSubsets(string[] items)
        {
            IEnumerable<string> allSubsets = new string[] { };
            int subsetLength = items.Length / 2;

            for (int i = 1; i <= subsetLength; i++)
            {
                IList<string> subsets = new List<string>();
                GenerateSubsetsRecursive(items, i, new string[items.Length], subsets, true);

                allSubsets = allSubsets.Concat(subsets);
            }

            return allSubsets;
        }

        private void GenerateSubsetsRecursive(string[] items, int subsetLength, string[] temp, IList<string> subsets, bool firstCall, int q = 0, int r = 0)
        {
            if (q == subsetLength)
            {
                StringBuilder sb = new StringBuilder();

                for (int i = 0; i < subsetLength; i++)
                {
                    sb.Append(temp[i]);
                }

                subsets.Add(sb.ToString());
            }

            else
            {
                for (int i = r; i < items.Length; i++)
                {
                    temp[q] = items[i];
                    GenerateSubsetsRecursive(items, subsetLength, temp, subsets, false, q + 1, i + 1);
                }
            }
        }

        private string[] GetRemaining(string[] child, string[] parent)
        {
            var parentList = parent.ToList();

            for (int i = 0; i < child.Length; i++)
            {
                for (int j = 0; j < parentList.Count; j++)
                {
                    if (child[i] == parentList[j])
                    {
                        parentList.RemoveAt(j);
                    }
                }
            }

            return parentList.ToArray();
        }

        private IList<Rule> GetStrongRules(double minConfidence, HashSet<Rule> rules, ItemsDictionary allFrequentItems)
        {
            var strongRules = new List<Rule>();

            foreach (Rule rule in rules)
            {
                string xy = CustomSort(rule.X + separator + rule.Y);
                AddStrongRule(rule, xy, strongRules, minConfidence, allFrequentItems);
            }

            strongRules.Sort();
            return strongRules;
        }

        private void AddStrongRule(Rule rule, string XY, List<Rule> strongRules, double minConfidence, ItemsDictionary allFrequentItems)
        {
            double confidence = GetConfidence(rule.X, XY, allFrequentItems);

            if (confidence >= minConfidence)
            {
                Rule newRule = new Rule(rule.X, rule.Y, confidence);
                strongRules.Add(newRule);
            }

            confidence = GetConfidence(rule.Y, XY, allFrequentItems);

            if (confidence >= minConfidence)
            {
                Rule newRule = new Rule(rule.Y, rule.X, confidence);
                strongRules.Add(newRule);
            }
        }

        private double GetConfidence(string X, string XY, ItemsDictionary allFrequentItems)
        {
            double supportX = allFrequentItems[X].Support;
            double supportXY = allFrequentItems[XY].Support;
            return supportXY / supportX;
        }


        private string CustomSort(string data)
        {
            var words = data.Split(separator);

            Array.Sort(words);

            string.Join(separator.ToString(), words);

            return string.Join(separator.ToString(), words);
        }

        #endregion
    }
}