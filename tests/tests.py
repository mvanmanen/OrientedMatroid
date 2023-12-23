import unittest
import circuit as cc


class TestCircuit(unittest.TestCase):
    def test_covector_validate_str(self):
        """
        Test the validate function
        """
        str1="++--0+-+"
        self.assertTrue(cc.covector_validate_str(str1))
        str1="+aaa--0+-+"
        self.assertFalse(cc.covector_validate_str(str1))

    def test_covector_get_int(self):
        str1="++--0+-+"
        int1=cc.covector_get_int(str1)
        str2=cc.covector_get_str(int1,len(str1))
        self.assertEqual(str1, str2)

    def test_covector_get_str(self):
        int1=345
        str2=cc.covector_get_str(int1,6)
        int2=cc.covector_get_int(str2)
        self.assertEqual(int1,int2)

    def test_covector_get_str_error(self):
        int1=345
        with self.assertRaises(RuntimeError):
            str2=cc.covector_get_str(int1,5)
        int1=-345
        with self.assertRaises(RuntimeError):
            str2=cc.covector_get_str(int1,5)

    def test_covector_combine_str(self):
        str1=     "0+--00-+"
        str2=     "-+000+-+"
        str1circ2="-+--0+-+"
        str1circ2test=cc.covector_combine_str(str1,str2)
        self.assertEqual(str1circ2,str1circ2test)

    def test_covector_combine_str(self):
        str1=     "0+--00-+"
        str2=     "-+000+-+"
        str1circ2="-+--0+-+"
        int1=cc.covector_get_int(str1)
        int2=cc.covector_get_int(str2)
        int1circ2=cc.covector_combine_int(int1,int2,len(str1))
        int1circ2test=cc.covector_get_int(str1circ2)
        self.assertEqual(int1circ2,int1circ2test)
        
if __name__ == '__main__':
    unittest.main()        

