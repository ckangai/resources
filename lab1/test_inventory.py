import unittest
from .inventory import Product

class TestProduct(unittest.TestCase):
    """Unit tests for the Product class."""

    def setUp(self):
        """Set up a clean environment for each test."""
        # Clear the class-level inventory before each test to ensure isolation
        Product._inventory.clear()

    def test_add_stock_new_product(self):
        """Test adding stock for a brand new product."""
        product = Product.add_stock("P001", "Laptop", 10)
        self.assertIn("P001", Product._inventory)
        self.assertEqual(product.name, "Laptop")
        self.assertEqual(product.stock, 10)
        self.assertEqual(Product._inventory["P001"].stock, 10)

    def test_add_stock_existing_product(self):
        """Test adding stock to an already existing product."""
        # First, create the product
        Product.add_stock("P002", "Mouse", 20)
        # Now, add more stock to it
        product = Product.add_stock("P002", "Mouse", 5)
        self.assertEqual(product.stock, 25)
        self.assertEqual(Product._inventory["P002"].stock, 25)

    def test_add_stock_invalid_amount(self):
        """Test that adding a non-positive amount raises a ValueError."""
        with self.assertRaisesRegex(ValueError, "The amount to add must be a positive integer."):
            Product.add_stock("P003", "Keyboard", 0)
        
        with self.assertRaisesRegex(ValueError, "The amount to add must be a positive integer."):
            Product.add_stock("P003", "Keyboard", -5)

    def test_remove_stock_success(self):
        """Test successfully removing stock from a product."""
        product = Product.add_stock("P004", "Webcam", 50)
        product.remove_stock(20)
        self.assertEqual(product.stock, 30)
        self.assertEqual(Product._inventory["P004"].stock, 30)

    def test_remove_stock_exact_amount(self):
        """Test removing the exact available amount of stock."""
        product = Product.add_stock("P005", "Monitor", 15)
        product.remove_stock(15)
        self.assertEqual(product.stock, 0)

    def test_remove_stock_insufficient_stock(self):
        """Test that removing more stock than available raises a ValueError."""
        product = Product.add_stock("P006", "Desk Chair", 10)
        with self.assertRaisesRegex(ValueError, "Cannot remove 11 items. Only 10 available."):
            product.remove_stock(11)

    def test_remove_stock_invalid_amount(self):
        """Test that removing a non-positive amount raises a ValueError."""
        product = Product.add_stock("P007", "USB Hub", 20)
        with self.assertRaisesRegex(ValueError, "The amount to remove must be a positive integer."):
            product.remove_stock(0)

        with self.assertRaisesRegex(ValueError, "The amount to remove must be a positive integer."):
            product.remove_stock(-5)

    def test_initial_stock_cannot_be_negative(self):
        """Test that a product cannot be created with negative stock."""
        with self.assertRaisesRegex(ValueError, "Stock cannot be negative."):
            Product("P008", "Invalid Product", -1)

if __name__ == '__main__':
    unittest.main()