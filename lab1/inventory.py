from __future__ import annotations
from typing import Dict, Union

class Product:
    """
    Represents a product and manages a shared inventory of all products.
    
    The inventory is stored in a class-level dictionary, allowing all
    product management to happen through the class itself.
    """
    _inventory: Dict[Union[str, int], Product] = {}

    def __init__(self, product_id: Union[str, int], name: str, stock: int = 0):
        self.product_id = product_id
        self.name = name
        if stock < 0:
            raise ValueError("Stock cannot be negative.")
        self.stock = stock

    @classmethod
    def add_stock(cls, product_id: Union[str, int], name: str, amount: int) -> Product:
        """Adds a new product or increases the stock of an existing one.

        If a product with the given ID doesn't exist, a new one is created.
        If it exists, its stock is increased by the given amount.

        Args:
            product_id: The unique identifier for the product.
            name: The name of the product (used if creating a new item).
            amount: The number of items to add to the stock.

        Returns:
            The Product instance, either new or updated.
        """
        if not isinstance(amount, int) or amount <= 0:
            raise ValueError("The amount to add must be a positive integer.")

        if product_id in cls._inventory:
            product = cls._inventory[product_id]
            product.stock += amount
            return product
        else:
            new_product = cls(product_id, name, amount)
            cls._inventory[product_id] = new_product
            return new_product

    def remove_stock(self, amount: int) -> None:
        """Decreases the product's stock by a given amount.

        Ensures that the stock does not go below zero.

        Args:
            amount (int): The number of items to remove from the stock.

        Raises:
            ValueError: If amount is not a positive integer, or if the
                        amount to remove is greater than the current stock.
        """
        if not isinstance(amount, int) or amount <= 0:
            raise ValueError("The amount to remove must be a positive integer.")
        if amount > self.stock:
            raise ValueError(f"Cannot remove {amount} items. Only {self.stock} available.")
        self.stock -= amount
